package edu.isi.bmkeg.lapdf.dao.vpdmf;

import java.io.File;
import java.io.StringWriter;
import java.util.List;

import org.apache.commons.io.FileUtils;
import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Scope;
import org.springframework.stereotype.Repository;
import org.springframework.web.context.WebApplicationContext;

import com.google.common.io.Files;

import edu.isi.bmkeg.ftd.model.FTD;
import edu.isi.bmkeg.ftd.model.FTDRuleSet;
import edu.isi.bmkeg.ftd.model.qo.FTDRuleSet_qo;
import edu.isi.bmkeg.ftd.model.qo.FTD_qo;
import edu.isi.bmkeg.lapdf.controller.LapdfVpdmfEngine;
import edu.isi.bmkeg.lapdf.dao.LAPDFTextDao;
import edu.isi.bmkeg.lapdf.model.LapdfDocument;
import edu.isi.bmkeg.lapdf.pmcXml.PmcXmlArticle;
import edu.isi.bmkeg.lapdf.xml.model.LapdftextXMLDocument;
import edu.isi.bmkeg.utils.Converters;
import edu.isi.bmkeg.utils.xml.XmlBindingTools;
import edu.isi.bmkeg.vpdmf.dao.CoreDao;
import edu.isi.bmkeg.vpdmf.dao.CoreDaoImpl;
import edu.isi.bmkeg.vpdmf.model.instances.LightViewInstance;

@Repository
public class LAPDFTextDaoImpl implements LAPDFTextDao {

	private static Logger logger = Logger.getLogger(LAPDFTextDaoImpl.class);
	
	// ~~~~~~~~~
	// Constants
	// ~~~~~~~~~

	@Autowired
	private CoreDao coreDao;
	
	private LapdfVpdmfEngine lapdfEng;

	// ~~~~~~~~~~~~
	// Constructors
	// ~~~~~~~~~~~~
	public LAPDFTextDaoImpl() {
	}	

	public LAPDFTextDaoImpl(CoreDao coreDao) {
		this.coreDao = coreDao;
	}	

	@Override
	public void init(String login, String password, String uri, String workingDirectory)
			throws Exception {
		
		if( coreDao == null ) {
			this.coreDao = new CoreDaoImpl();
		}
		
		this.coreDao.init(login, password, uri, workingDirectory);
		
	}
	
	// ~~~~~~~~~~~~~~~~~~~
	// Getters and Setters
	// ~~~~~~~~~~~~~~~~~~~
	public void setCoreDao(CoreDao dlVpdmf) {
		this.coreDao = dlVpdmf;
	}

	public CoreDao getCoreDao() {
		return coreDao;
	}
	
	
	
	
	@Override
	public void insertLapdfDocument(LapdfDocument doc, File pdf, String text) throws Exception {

		FTD ftd = new FTD();
		
		ftd.setChecksum( Converters.checksum(pdf) );
		ftd.setName( pdf.getPath() );
	
		getCoreDao().insert(ftd, "FTD");
		
	}
	
	public FTD runRuleSetOnFtd(FTD ftd, FTDRuleSet ftdRuleSet) throws Exception {
		
		/**
		 *  TODO: NEED A MUCH CLEANER IMPLEMENTATION OF THIS 
		 * 
		// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// Update the representation of the ruleset in the database.
		// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~		
		FTDRuleSet_qo ftdRs_qo = new FTDRuleSet_qo();
		ftdRs_qo.setFileName(ftdRuleSet.getFileName());
		List<LightViewInstance> l = this.coreDao.list(ftdRs_qo, "FTDRuleSet");
		
		// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// Dump rulefile to disk on server
		// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		String wdPth = this.getCoreDao().getWorkingDirectory();
		File ruleDir = new File(wdPth + "/rules");
		File ruleFile = new File( ruleDir.getPath() + "/" 
				+ ftdRuleSet.getFileName());
		String s = ftdRuleSet.getFileName();
		ftdRuleSet.setRsName(s.substring(0,s.length()-4));
		ftdRuleSet.setRsDescription("");
		
		if( l.size() == 1 ) {
			
			FTDRuleSet rsInDb = new FTDRuleSet();
			rsInDb = this.coreDao.findById(
					l.get(0).getVpdmfId(), 
					rsInDb, 
					"FTDRuleSet");
			
			rsInDb.setRsName( ftdRuleSet.getRsName() );
			rsInDb.setRsDescription( ftdRuleSet.getRsDescription() );
			rsInDb.setRuleBody( ftdRuleSet.getRuleBody() );
			rsInDb.setCsv( ftdRuleSet.getCsv() );
			rsInDb.setExcelFile( ftdRuleSet.getExcelFile() );
			this.coreDao.update(rsInDb, "FTDRuleSet");
			
		} else if(l.size() == 0) {

			long vpdmfId = this.coreDao.insert(ftdRuleSet, "FTDRuleSet");
			ftdRuleSet.setVpdmfId(vpdmfId);
			
		} else {
			throw new Exception("Ambiguous Number of Rule Sets for file " 
					+ ftdRuleSet.getFileName());
		}
		
		// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// Get the original LAPDFtext Document
		// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		this.lapdfEng = new LapdfVpdmfEngine(ruleFile);
		
		LapdfDocument document = this.lapdfEng.blockifyXml( ftd.getXml() );
		
		this.lapdfEng.classifyDocument(document, ruleFile);
		
		// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// Update the representation of the ruleset in the database.
		// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~				
		FTD_qo ftd_qo = new FTD_qo();
		ftd_qo.setName( ftd.getName() );
		ftd_qo.setChecksum( ftd.getChecksum() );
		l = this.coreDao.list(ftd_qo, "FTD");
		
		if( l.size() == 1 ) {

			FTD ftdInDb = new FTD();
			ftdInDb = this.coreDao.findById(
					l.get(0).getVpdmfId(), 
					ftdInDb, 
					"FTD");
			
			PmcXmlArticle pmcXml = document.convertToPmcXmlFormat();
			StringWriter writer = new StringWriter();
			XmlBindingTools.generateXML(pmcXml, writer);
			ftdInDb.setPmcXml( writer.toString() );
			
			LapdftextXMLDocument lapdfXml = document.convertToLapdftextXmlFormat();
			writer = new StringWriter();
			XmlBindingTools.generateXML(lapdfXml, writer);		
			String str = writer.toString();
			ftdInDb.setXml( str );

			ftdInDb.setRuleSet( ftdRuleSet );
			
			this.coreDao.update(ftdInDb, "FTD");

		} else if( l.size() == 0 ){
			
			PmcXmlArticle pmcXml = document.convertToPmcXmlFormat();
			StringWriter writer = new StringWriter();
			XmlBindingTools.generateXML(pmcXml, writer);
			ftd.setPmcXml( writer.toString() );

			LapdftextXMLDocument lapdfXml = document.convertToLapdftextXmlFormat();
			writer = new StringWriter();
			XmlBindingTools.generateXML(lapdfXml, writer);		
			String str = writer.toString();
			ftd.setXml( str );
			
			ftd.setRuleSet( ftdRuleSet );
			this.coreDao.insert(ftd, "FTD");
			
		}
		
		Converters.recursivelyDeleteFiles(tempDir);
		*/
		return ftd;
		
	}

}
