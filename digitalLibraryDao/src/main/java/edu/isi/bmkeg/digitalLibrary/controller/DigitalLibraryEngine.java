package edu.isi.bmkeg.digitalLibrary.controller;

import java.io.BufferedReader;

import java.io.DataInputStream;
import java.io.File;
import java.io.FileFilter;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.StringWriter;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

import org.apache.commons.io.FileUtils;
import org.apache.log4j.Logger;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.nodes.Node;
import org.jsoup.select.Elements;
import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.Resource;

import edu.isi.bmkeg.digitalLibrary.dao.DigitalLibraryDao;
import edu.isi.bmkeg.digitalLibrary.dao.ExtendedDigitalLibraryDao;
import edu.isi.bmkeg.digitalLibrary.dao.impl.DigitalLibraryDaoImpl;
import edu.isi.bmkeg.digitalLibrary.dao.impl.ExtendedDigitalLibraryDaoImpl;
import edu.isi.bmkeg.digitalLibrary.model.citations.ArticleCitation;
import edu.isi.bmkeg.digitalLibrary.model.citations.Corpus;
import edu.isi.bmkeg.digitalLibrary.model.citations.ID;
import edu.isi.bmkeg.digitalLibrary.model.citations.Journal;
import edu.isi.bmkeg.digitalLibrary.model.citations.JournalEpoch;
import edu.isi.bmkeg.digitalLibrary.model.citations.URL;
import edu.isi.bmkeg.digitalLibrary.model.qo.citations.ArticleCitation_qo;
import edu.isi.bmkeg.digitalLibrary.model.qo.citations.ID_qo;
import edu.isi.bmkeg.digitalLibrary.utils.FileLookupPersistentObject;
import edu.isi.bmkeg.digitalLibrary.utils.JournalLookupPersistentObject;
import edu.isi.bmkeg.digitalLibrary.utils.pubmed.BuildCitationFromMedlineMetaData;
import edu.isi.bmkeg.digitalLibrary.utils.pubmed.EFetcher;
import edu.isi.bmkeg.digitalLibrary.utils.pubmed.VpdmfMedlineHandler;
import edu.isi.bmkeg.ftd.dao.FtdDao;
import edu.isi.bmkeg.ftd.model.FTD;
import edu.isi.bmkeg.ftd.model.FTDRuleSet;
import edu.isi.bmkeg.ftd.model.qo.FTD_qo;
import edu.isi.bmkeg.lapdf.controller.LapdfVpdmfEngine;
import edu.isi.bmkeg.lapdf.dao.vpdmf.LAPDFTextDaoImpl;
import edu.isi.bmkeg.lapdf.extraction.exceptions.EncryptionException;
import edu.isi.bmkeg.lapdf.model.LapdfDocument;
import edu.isi.bmkeg.lapdf.xml.model.LapdftextXMLDocument;
import edu.isi.bmkeg.utils.Converters;
import edu.isi.bmkeg.utils.xml.XmlBindingTools;
import edu.isi.bmkeg.vpdmf.dao.CoreDao;
import edu.isi.bmkeg.vpdmf.model.instances.LightViewInstance;

public class DigitalLibraryEngine extends LapdfVpdmfEngine {

	private static Logger logger = Logger.getLogger(DigitalLibraryEngine.class);

	// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	private DigitalLibraryDao digLibDao;
	private ExtendedDigitalLibraryDao extDigLibDao;
	private FtdDao ftdDao;

	private Map<String, Journal> jLookup;
	private Map<String, File> fLookup;

	// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	public DigitalLibraryEngine() throws Exception {
		super();
	}

	public DigitalLibraryEngine(File pdfRuleFile) throws Exception {
		super(pdfRuleFile);
	}

	// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	// VPDMf functions
	// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	/**
	 * Builds dao objects to input and output data to a VPDMf store.
	 */
	public void initializeVpdmfDao(String login, String password,
			String dbName, String workingDirectory) throws Exception {

		super.initializeVpdmfDao(login, password, dbName, workingDirectory);

		CoreDao coreDao = this.getFtdDao().getCoreDao();
		this.setFtdDao(new LAPDFTextDaoImpl(coreDao));
		this.digLibDao = new DigitalLibraryDaoImpl(coreDao);
		this.extDigLibDao = new ExtendedDigitalLibraryDaoImpl(coreDao);

		// Build lookup table from journals on disk (persistent object)
		this.setjLookup(JournalLookupPersistentObject.readJLookup(dbName,
				login, password, workingDirectory));

	}

	// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	public ExtendedDigitalLibraryDao getExtDigLibDao() {
		return extDigLibDao;
	}

	public void setCitDao(ExtendedDigitalLibraryDao citDao) {
		this.extDigLibDao = citDao;
	}

	public Map<String, Journal> getjLookup() {
		return jLookup;
	}

	public void setjLookup(Map<String, Journal> jLookup) {
		this.jLookup = jLookup;
	}

	public Map<String, File> getfLookup() {
		return fLookup;
	}

	public void setfLookup(Map<String, File> fLookup) {
		this.fLookup = fLookup;
	}

	public DigitalLibraryDao getDigLibDao() {
		return digLibDao;
	}

	public void setDigLibDao(DigitalLibraryDao digLibDao) {
		this.digLibDao = digLibDao;
	}

	// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	// Loading data.
	// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	public Map<Integer, Map<String, String>> loadIdMapFromPmidFile(File pmidFile)
			throws Exception {

		// Load file line by line as Map<String, Map<String,String>>
		Map<Integer, Map<String, String>> idMap = new HashMap<Integer, Map<String, String>>();
		FileInputStream fstream = new FileInputStream(pmidFile);

		// Get the object of DataInputStream
		DataInputStream in = new DataInputStream(fstream);
		BufferedReader br = new BufferedReader(new InputStreamReader(in));

		String strLine;
		List<String> missedLines = new ArrayList<String>();
		while ((strLine = br.readLine()) != null) {
			String[] splitLn = strLine.split("\\t+");
			String pmid = splitLn[0];
			Map<String, String> otherIds = new HashMap<String, String>();
			for (int i = 1; i < splitLn.length; i++) {
				String[] splitId = splitLn[i].split(":");
				otherIds.put(splitId[0], splitId[1]);
			}
			try {
				idMap.put(new Integer(pmid), otherIds);
			} catch (NumberFormatException e) {
				missedLines.add(strLine);
			}
		}
		in.close();

		return idMap;

	}

	public Set<Integer> loadIdSetFromPmidFile(File pmidFile) throws Exception {

		// Load file line by line as Map<String, Map<String,String>>
		Set<Integer> idSet = new HashSet<Integer>();

		if (pmidFile == null)
			return idSet;

		FileInputStream fstream = new FileInputStream(pmidFile);

		// Get the object of DataInputStream
		DataInputStream in = new DataInputStream(fstream);
		BufferedReader br = new BufferedReader(new InputStreamReader(in));

		String strLine;
		Pattern p = Pattern.compile("^\\d+$");
		List<String> missedLines = new ArrayList<String>();
		while ((strLine = br.readLine()) != null) {
			String[] splitLn = strLine.split("\\t+");
			String pmid = splitLn[0];
			Matcher m = p.matcher(pmid);
			if (!m.find()) {
				continue;
			}
			idSet.add(new Integer(pmid));
		}
		in.close();

		return idSet;

	}

	public Map<Integer, Long> insertPmidPdfFileOrDir(File pdfOrDir)
			throws Exception {
		return this.insertPmidPdfFileOrDir(pdfOrDir, true);
	}

	public Map<Integer, Long> insertPmidPdfFileOrDir(File pdfOrDir,
			boolean skipExisting) throws Exception {

		Map<Integer, Long> pmidLookup = new HashMap<Integer, Long>();

		File workDir = new File(this.extDigLibDao.getCoreDao()
				.getWorkingDirectory());

		if (pdfOrDir.isDirectory()) {

			Pattern p = Pattern.compile("\\.pdf$");
			List<File> pdfList = new ArrayList<File>(Converters
					.recursivelyListFiles(pdfOrDir, p).values());
			Collections.sort(pdfList);
			Iterator<File> pdfIt = pdfList.iterator();
			LOOP: while (pdfIt.hasNext()) {
				File pdf = pdfIt.next();

				try {

					ArticleCitation ac = insertCodedPdfFileName(pdf.getName(),
							"pmid");

					if (skipExisting) {
						FTD_qo ftdQo = new FTD_qo();
						ArticleCitation_qo acQo = new ArticleCitation_qo();
						ftdQo.setCitation(acQo);
						acQo.setVpdmfId(ac.getVpdmfId() + "");
						if (this.digLibDao.getCoreDao().countViewInTrans(ftdQo,
								"ArticleDocument") == 1) {
							logger.info("skipping " + ac.getVpdmfLabel());
							continue LOOP;
						}
					}
					
					this.applyLapdfToFile(ac, pdf);
					
					this.extDigLibDao.addFtdToArticleCitation(ac, pdf);

					pmidLookup.put(ac.getPmid(), ac.getVpdmfId());

				} catch (EncryptionException e) {

					logger.warn("Can't parse " + pdf.getPath()
							+ ", file is encrypted.");

				} catch (Exception e2) {

					e2.printStackTrace();
					logger.warn("Error with file " + pdf.getPath() + ", "
							+ e2.getMessage());

				}

			}

		} else {

			ArticleCitation ac = insertCodedPdfFileName(pdfOrDir.getName(),
					"pmid");

			this.applyLapdfToFile(ac, pdfOrDir);
			
			this.extDigLibDao.addFtdToArticleCitation(ac, pdfOrDir);

			pmidLookup.put(ac.getPmid(), ac.getVpdmfId());

		}

		return pmidLookup;

	}
	
	public void applyLapdfToFile(ArticleCitation ac, File pdf) throws Exception {
		String wdPath = this.extDigLibDao.getCoreDao().getWorkingDirectory();
		File wd = new File(wdPath);
		String dirPth = "pdfs/" + ac.getJournal().getAbbr() + "/"
				+ ac.getPubYear() + "/" + ac.getVolValue();
		dirPth = dirPth.replaceAll("\\s+", "_");
		File pdfDir = new File(wd + "/" + dirPth);					
		File lapdfFile = new File(pdfDir.getPath() + "/" +
				pdf.getName().replaceAll("\\.pdf$", "_lapdf.xml"));
		
		if( !lapdfFile.exists() ) {
			LapdfDocument doc = this.blockifyFile(pdf);

			JournalEpoch je = this.extDigLibDao
					.retriveJournalEpochForCitation(ac);
			if (je != null && je.getRules() != null) {
				FTDRuleSet rs = je.getRules();
				File ruleFile = new File(wd.getPath() + "/"
						+ rs.getFilePath());
				this.classifyDocument(doc, ruleFile);
			}
			LapdftextXMLDocument xml = doc.convertToLapdftextXmlFormat();
			FileWriter writer = new FileWriter(lapdfFile);
			XmlBindingTools.generateXML(xml, writer);
		}
	}

	public ArticleCitation insertCodedPdfFileName(String s, String idCode)
			throws Exception {

		CoreDao coreDao = this.digLibDao.getCoreDao();

		Pattern p = Pattern.compile("^(\\d+)");
		Matcher m = p.matcher(s);

		Integer id = -1;

		if (m.find()) {

			id = new Integer(m.group(1));

		} else {

			Pattern p2 = Pattern
					.compile("^(\\w+)[_\\-](\\d+)[_\\-](\\d+)[_\\-](\\w+)\\.pdf$");
			Matcher m2 = p2.matcher(s);

			if (m2.find()) {

				String au = m2.group(1);
				String dp = m2.group(2);
				String vi = m2.group(3);
				String pg = m2.group(4);

				BuildCitationFromMedlineMetaData ml = new BuildCitationFromMedlineMetaData();
				id = ml.getPMIDFromMetadata(au, dp, vi, pg);

				if (id == -1)
					throw new Exception("Can't get PMID from filename: " + s);

			} else {
				throw new Exception("Can't get PMID from filename: " + s);
			}

		}

		LightViewInstance ftdLvi = null;
		LightViewInstance acLvi = null;
		if (idCode.equals("pmid")) {

			FTD_qo ftdQ = new FTD_qo();
			ArticleCitation_qo acQ = new ArticleCitation_qo();
			acQ.setPmid(id.toString());
			ftdQ.setCitation(acQ);

			List<LightViewInstance> ftdL = this.extDigLibDao.getCoreDao()
					.listInTrans(ftdQ, "ArticleDocument");
			if (ftdL.size() == 1)
				ftdLvi = ftdL.get(0);

			List<LightViewInstance> acL = this.extDigLibDao.getCoreDao()
					.listInTrans(acQ, "ArticleCitation");
			if (acL.size() == 1)
				acLvi = acL.get(0);

		} else {

			FTD_qo ftdQ = new FTD_qo();
			ArticleCitation_qo acQ = new ArticleCitation_qo();
			ftdQ.setCitation(acQ);
			ID_qo idQ = new ID_qo();
			acQ.getIds().add(idQ);
			idQ.setIdType(idCode);
			idQ.setIdValue(id.toString());

			List<LightViewInstance> ftdL = this.digLibDao.getCoreDao()
					.listInTrans(ftdQ, "ArticleDocument");
			if (ftdL.size() == 1)
				ftdLvi = ftdL.get(0);

			List<LightViewInstance> acL = this.extDigLibDao.getCoreDao()
					.listInTrans(acQ, "ArticleCitation");
			if (acL.size() == 1)
				acLvi = acL.get(0);

		}

		ArticleCitation ac = null;
		if (idCode.equals("pmid")) {

			ArticleCitation_qo acQ = new ArticleCitation_qo();
			acQ.setPmid(id + "");
			List<LightViewInstance> acList = coreDao.listInTrans(acQ,
					"ArticleCitation");

			if (acList.size() == 0) {

				List<Integer> ii = new ArrayList<Integer>();
				ii.add(id);
				List<ArticleCitation> ll = this
						.insertArticlesFromPmidList_inTrans(ii);
				if (ll == null || ll.size() == 0) {
					throw new Exception(idCode + ":" + id
							+ " cannot be inserted");
				}
				ac = ll.get(0);

			} else {

				LightViewInstance lvi = acList.get(0);
				ac = this.digLibDao.getCoreDao().findByIdInTrans(
						acList.get(0).getVpdmfId(), new ArticleCitation(),
						"ArticleCitation");

			}

		} else {

			ac = this.extDigLibDao.findArticleByIdInTrans(idCode, id);

		}

		if (ac == null) {
			throw new Exception(idCode + ":" + id + " cannot found in database");
		}

		return ac;

	}

	public Map<Integer, Long> updatePmidPdfFileOrDir(File pdfOrDir,
			boolean forceBlockify) throws Exception {

		Map<Integer, Long> pmidLookup = new HashMap<Integer, Long>();

		if (pdfOrDir.isDirectory()) {

			Pattern p = Pattern.compile("\\.pdf$");
			List<File> pdfList = new ArrayList<File>(Converters
					.recursivelyListFiles(pdfOrDir, p).values());
			Collections.sort(pdfList);
			Iterator<File> pdfIt = pdfList.iterator();
			while (pdfIt.hasNext()) {
				File pdf = pdfIt.next();

				pmidLookup
						.putAll(updateCodedPdfFile(pdf, "pmid", forceBlockify));

			}

		} else {

			pmidLookup.putAll(updateCodedPdfFile(pdfOrDir, "pmid",
					forceBlockify));

		}

		return pmidLookup;

	}

	public Map<Integer, Long> updateCodedPdfFile(File pdf, String idCode,
			boolean forceBlockify) throws Exception {

		Map<Integer, Long> map = new HashMap<Integer, Long>();

		long t = System.currentTimeMillis();
		this.getExtDigLibDao().getCoreDao().connectToDb();

		try {

			String s = pdf.getName();
			Pattern p = Pattern.compile("^(\\d+)");
			Matcher m = p.matcher(s);

			if (!m.find())
				return new HashMap<Integer, Long>();

			Integer id = new Integer(m.group(1));

			ArticleCitation ac = null;
			FTD ftd = null;
			if (idCode.equals("pmid")) {
				ac = this.extDigLibDao.findArticleByPmidInTrans(id);
				ftd = this.extDigLibDao.findArticleDocumentByPmidInTrans(id);
			} else {
				ac = this.extDigLibDao.findArticleByIdInTrans(idCode, id);
				ftd = this.extDigLibDao.findArticleDocumentByIdInTrans(idCode,
						id);
			}

			if (ac == null) {
				return map;
			}

			if (ftd == null || forceBlockify) {

				LapdfDocument doc = this.blockifyFile(pdf);

				this.applyLapdfToFile(ac, pdf);

				this.extDigLibDao.addFtdToArticleCitation(ac, pdf);

			} else if (ftd.getLaswfFile() == null) {

				this.extDigLibDao.addSwfToFtd(pdf, ftd);
				this.getFtdDao().getCoreDao().update(ftd, "FTD");

			} else {

				logger.info("PMID: " + idCode + ", nothing to update");

			}

			long deltaT = System.currentTimeMillis() - t;
			logger.info("Aded PDF to article (" + idCode + ":" + id + ") in "
					+ deltaT / 1000 + " s");

			map.put(ac.getPmid(), ac.getVpdmfId());

			this.getExtDigLibDao().getCoreDao().commitTransaction();

		} catch (edu.isi.bmkeg.lapdf.extraction.exceptions.EncryptionException e) {

			logger.info("PMID: " + idCode + ", file is encrypted");
			return new HashMap<Integer, Long>();

		}  catch (Exception e2) {

			logger.info("PMID: " + idCode + ", error");
			return new HashMap<Integer, Long>();

		} finally {

			this.getExtDigLibDao().getCoreDao().closeDbConnection();

		}

		return map;

	}

	public Map<Integer, Long> buildPmidLookup(Set<Integer> pmids)
			throws Exception {

		return (getExtDigLibDao().lookupPmidsInTrans(pmids));

	}

	public void insertArticlesFromPmidList(File pmidFile) throws Exception {

		// Load file line by line as Map<String, Map<String,String>>
		Map<Integer, Map<String, String>> idMap = this
				.loadIdMapFromPmidFile(pmidFile);

		this.loadArticlesFromPmidList(idMap, new HashSet<Integer>());

	}

	public void insertArticlesFromPmidList(File pmidFile, Set<Integer> pmidsInDb)
			throws Exception {

		// Load file line by line as Map<String, Map<String,String>>
		Map<Integer, Map<String, String>> idMap = this
				.loadIdMapFromPmidFile(pmidFile);

		Set<Integer> difference = new HashSet<Integer>(idMap.keySet());
		difference.removeAll(pmidsInDb);

		this.loadArticlesFromPmidList(idMap, pmidsInDb);

	}

	/**
	 * Given a set of pubmed id values (pmids), insert one ArticleCitation per
	 * pmid.
	 * 
	 * @param pmidsToAdd
	 * @return
	 * @throws Exception
	 */
	public List<ArticleCitation> insertArticlesFromPmidList_inTrans(
			List<Integer> pmidsToAdd) throws Exception {

		return this.insertArticlesFromPmidList_inTrans(pmidsToAdd,
				new HashMap<Integer, String>());

	}

	public List<ArticleCitation> insertArticlesFromPmidList_inTrans(
			List<Integer> pmidsToAdd, Map<Integer, String> ftdLocations)
			throws Exception {

		List<ArticleCitation> l = new ArrayList<ArticleCitation>();

		// run checks
		// Map<Integer, Long> pmidsInDb =
		// this.getExtDigLibDao().lookupPmidsInTrans(pmidsToAdd, 1000);
		Set<Integer> toAdd = new HashSet<Integer>(pmidsToAdd);
		// toAdd.removeAll(pmidsInDb.keySet());

		EFetcher f = new EFetcher(toAdd);
		while (f.hasNext()) {
			ArticleCitation a = f.next();

			if (a == null)
				continue;

			if (a.getAuthorList() == null || a.getAuthorList().size() == 0)
				continue;

			if (a.getVolume() == null) {
				a.setVolume("-");
				a.setVolValue(-1);
			}

			if (a.getIssue() == null)
				a.setIssue("-");

			if (a.getPages() == null)
				a.setPages("-");

			String jStr = a.getJournal().getAbbr();
			if (!getjLookup().containsKey(jStr)) {
				logger.info("'" + jStr
						+ "' not found in lookup, skipping PMID=" + a.getPmid());
				continue;
			}

			Journal j = getjLookup().get(jStr);
			a.setJournal(j);

			if (ftdLocations.containsKey(a.getPmid())) {
				URL u = new URL();
				u.setResource(a);
				u.setUrl(ftdLocations.get(a.getPmid()));
				a.getFullTextUrl().add(u);
			}

			try {

				logger.info("adding PMID=" + a.getPmid());
				getExtDigLibDao().getCoreDao().insertInTrans(a,
						"ArticleCitation");

				l.add(a);

			} catch (Exception e) {
				logger.error("article insert failed, PMID=" + a.getPmid());
				logger.error(e.getMessage());
			}

		}

		return l;

	}

	public List<ArticleCitation> insertArticlesFromPmidList(
			List<Integer> pmidsToAdd, Map<Integer, String> ftdLocations)
			throws Exception {

		List<ArticleCitation> l = new ArrayList<ArticleCitation>();

		// run checks
		this.digLibDao.getCoreDao().connectToDb();
		Map<Integer, Long> pmidsInDb = this.getExtDigLibDao()
				.listAllPmidsInTrans();
		this.digLibDao.getCoreDao().closeDbConnection();

		Set<Integer> toAdd = new HashSet<Integer>(pmidsToAdd);
		toAdd.removeAll(pmidsInDb.keySet());

		EFetcher f = new EFetcher(toAdd);
		while (f.hasNext()) {
			ArticleCitation a = f.next();

			if (a == null)
				continue;

			if (a.getAuthorList() == null || a.getAuthorList().size() == 0)
				continue;

			if (a.getVolume() == null) {
				a.setVolume("-");
				a.setVolValue(-1);
			}

			if (a.getIssue() == null)
				a.setIssue("-");

			if (a.getPages() == null)
				a.setPages("-");

			String jStr = a.getJournal().getAbbr();
			if (!getjLookup().containsKey(jStr)) {
				logger.info("'" + jStr
						+ "' not found in lookup, skipping PMID=" + a.getPmid());
				continue;
			}

			Journal j = getjLookup().get(jStr);
			a.setJournal(j);

			if (ftdLocations.containsKey(a.getPmid())) {
				URL u = new URL();
				u.setResource(a);
				u.setUrl(ftdLocations.get(a.getPmid()));
				a.getFullTextUrl().add(u);
			}

			try {

				logger.info("adding PMID=" + a.getPmid());
				getExtDigLibDao().getCoreDao().insert(a, "ArticleCitation");

				l.add(a);

			} catch (Exception e) {
				logger.error("article insert failed, PMID=" + a.getPmid());
				logger.error(e.getMessage());
			}

		}

		return l;

	}

	public void loadArticlesFromPmidList(
			Map<Integer, Map<String, String>> pmidsToAdd,
			Set<Integer> pmidsToSkip) throws Exception {

		EFetcher f = new EFetcher(pmidsToAdd.keySet(), pmidsToSkip);
		while (f.hasNext()) {
			ArticleCitation a = f.next();

			if (a == null)
				return;

			String jStr = a.getJournal().getAbbr();
			if (!getjLookup().containsKey(jStr)) {
				logger.info("'" + jStr
						+ "' not found in lookup, skipping PMID=" + a.getPmid());
				continue;
			}

			Journal j = getjLookup().get(jStr);
			a.setJournal(j);

			Map<String, String> idKeysMap = pmidsToAdd.get(a.getPmid());
			if (idKeysMap == null) {
				logger.info("Can't find PMID=" + a.getPmid()
						+ " in original map, very strange.");
			} else {
				Iterator<String> keyIt = idKeysMap.keySet().iterator();
				while (keyIt.hasNext()) {
					String key = keyIt.next();
					ID id = new ID();
					id.setPublication(a);
					a.getIds().add(id);
					id.setIdType(key);
					id.setIdValue(idKeysMap.get(key));
				}
			}

			try {
				logger.info("inserting article, PMID=" + a.getPmid());
				getExtDigLibDao().getCoreDao().insert(a, "ArticleCitation");
			} catch (Exception e) {
				logger.info("article insert failed, PMID=" + a.getPmid());
				e.printStackTrace();
			}

		}

	}

	public void loadArticlesFromPmidListToCorpus(File pmidFile,
			String corpusName) throws Exception {

		// Load file line by line as Map<String, Map<String,String>>
		Map<Integer, Map<String, String>> idMap = this
				.loadIdMapFromPmidFile(pmidFile);

		List<Integer> ids = new ArrayList<Integer>(idMap.keySet());
		Collections.sort(ids);

		this.getExtDigLibDao().addArticlesToCorpus(ids, corpusName);

	}

	public void loadArticlesFromPmidListToCorpus(List<Integer> pmids,
			String corpusName) throws Exception {

		this.getExtDigLibDao().addArticlesToCorpus(pmids, corpusName);

	}

	public void deleteArticleCitations(File pmidFile) throws Exception {

		Map<Integer, Map<String, String>> idMap = this
				.loadIdMapFromPmidFile(pmidFile);

		List<Integer> ids = new ArrayList<Integer>(idMap.keySet());
		Collections.sort(ids);
		Iterator<Integer> idIt = ids.iterator();
		while (idIt.hasNext()) {
			Integer id = idIt.next();

			ArticleCitation_qo acQo = new ArticleCitation_qo();
			acQo.setPmid(id + "");
			List<LightViewInstance> listLvi = this.digLibDao
					.listArticleCitation(acQo);

			if (listLvi.size() == 1) {
				try {
					this.digLibDao.deleteArticleCitationById(listLvi.get(0)
							.getVpdmfId());
				} catch (Exception e) {
					logger.info("Can't delete article "
							+ listLvi.get(0).getVpdmfLabel());
				}

			}

		}

	}

	public void deleteArticleCitationsFromCorpus(File pmidFile,
			String corpusName) throws Exception {

		Map<Integer, Map<String, String>> idMap = this
				.loadIdMapFromPmidFile(pmidFile);

		Corpus c = this.extDigLibDao.findCorpusByNameInTrans(corpusName);

		List<Integer> ids = new ArrayList<Integer>(idMap.keySet());
		Collections.sort(ids);
		Iterator<Integer> idIt = ids.iterator();
		while (idIt.hasNext()) {
			Integer id = idIt.next();

			ArticleCitation_qo acQo = new ArticleCitation_qo();
			acQo.setPmid(id + "");
			List<LightViewInstance> listLvi = this.digLibDao
					.listArticleCitation(acQo);
			if (listLvi.size() != 1) {
				continue;
			}

			LightViewInstance lvi = listLvi.get(0);
			ArticleCitation a = this.digLibDao.findArticleCitationById(lvi
					.getVpdmfId());

			Iterator<Corpus> ccIt = a.getCorpora().iterator();
			Corpus cc = null;
			boolean found = false;
			while (ccIt.hasNext() && !found) {
				cc = ccIt.next();
				if (cc.getName().equals(c.getName())) {
					found = true;
				}
			}

			a.getCorpora().remove(cc);

			this.digLibDao.updateArticleCitation(a);

		}

	}

	public void loadMedlineArchiveDirectory(File dir) throws Exception {

		FileFilter archiveFilesFilter = new FileFilter() {
			public boolean accept(File file) {

				if (!file.getName().contains("medline"))
					return false;

				String p = file.getAbsolutePath();
				if (p.endsWith(".xml") || p.endsWith(".gz")
						|| p.endsWith(".bz2"))
					return true;

				return false;

			}
		};

		File[] list = dir.listFiles(archiveFilesFilter);
		int recsInDir = 0;

		FileLookupPersistentObject fLookupPO = new FileLookupPersistentObject();
		this.fLookup = fLookupPO.getfLookup();

		for (int k = 0; k < list.length; k++) {
			File f = list[k];

			if (!this.getfLookup().containsKey(f.getName())) {

				VpdmfMedlineHandler cmh = new VpdmfMedlineHandler(this.jLookup);

				List<ArticleCitation> aList = cmh.parseMedlineFileToList(f);
				for (ArticleCitation a : aList) {
					getExtDigLibDao().getCoreDao().insert(a, "ArticleCitation");
				}

				this.getfLookup().put(f.getName(), f);
				fLookupPO.setfLookup(this.getfLookup());
				fLookupPO.saveFileLookupFile();

			} else {

				logger.info(f.getPath() + " file already parsed, skipped.");

			}

		}

	}

}
