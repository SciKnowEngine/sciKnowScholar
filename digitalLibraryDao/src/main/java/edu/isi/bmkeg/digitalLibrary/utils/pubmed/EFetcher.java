package edu.isi.bmkeg.digitalLibrary.utils.pubmed;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.URL;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.xml.parsers.SAXParser;
import javax.xml.parsers.SAXParserFactory;

import org.apache.log4j.Logger;
import org.xml.sax.InputSource;

import edu.isi.bmkeg.digitalLibrary.model.citations.ArticleCitation;
import edu.isi.bmkeg.digitalLibrary.model.citations.Journal;

public class EFetcher 
{	

	private static Logger logger = Logger.getLogger(EFetcher.class);
	
	private static String JOURNALS = "journals";	
	private static String PUBMED = "pubmed";
	
	private String baseQueryPrefix = 
			"http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=" + PUBMED + "&id=";
	private String baseQuerySuffix = "&retmode=xml";
	
	private int pageCapacity = 500;
	private int startOfPage = 0;
	private int counter = 0;
	private int maxCount = -1;
	
	//
	// allIds are all the ids originally assigned
	// INCLUDING all those designated to be skipped
	// as an EFetch query.
	//
	private Set<Integer> allIds = new HashSet<Integer>();

	private List<Integer> ids = new ArrayList<Integer>();
	private Set<Integer> toSkip = new HashSet<Integer>();
	private List<ArticleCitation> articles = new ArrayList<ArticleCitation>();
	
	// Special functionality to run the Esearcher.
	private ESearcher eSearcher;
	
	public EFetcher( Set<Integer> ids) throws Exception {
		this.getAllIds().addAll(ids);
		this.ids.addAll(ids);		
		this.maxCount = ids.size();
		this.articles = this.executeEFetch();
	}
	
	public EFetcher( Set<Integer> ids, int capacity) throws Exception {
		this.pageCapacity = capacity;
		this.ids.addAll(ids);
		this.getAllIds().addAll(ids);
		this.maxCount = ids.size();
		this.articles = this.executeEFetch();
	}

	public EFetcher( Set<Integer> ids,  int capacity, Set<Integer> toSkip) throws Exception {
		this.getAllIds().addAll(ids);
		this.ids.addAll(ids);		
		this.ids.removeAll(toSkip);
		this.maxCount = ids.size();
		this.pageCapacity = capacity;
		this.articles = this.executeEFetch();
	}

	public EFetcher( Set<Integer> ids, Set<Integer> toSkip) throws Exception {
		this.getAllIds().addAll(ids);
		this.ids.addAll(ids);		
		this.ids.removeAll(toSkip);
		this.maxCount = this.ids.size();
		this.articles = this.executeEFetch();
	}

	public EFetcher( String queryString, Set<Integer> toSkip) throws Exception {
		this.toSkip.addAll(toSkip);
		this.eSearcher = new ESearcher(queryString);
		this.maxCount = this.eSearcher.getMaxCount();
		this.articles = this.executeEFetch();
	}	

	public Set<Integer> getAllIds() {
		return allIds;
	}
	
	public boolean hasNext() {
		if( this.startOfPage + this.counter < this.maxCount ){
			return true;
		}
		return false;
	}
	
	public ArticleCitation next() throws Exception {

		if( this.counter >= this.articles.size() ) {
			this.startOfPage += this.pageCapacity; 
			this.counter = 0;
			this.articles = this.executeEFetch();
		}
		
		if(this.articles == null) {
			counter++;
			return null;
		}
		
		ArticleCitation next = this.articles.get(counter);
		counter++;

		return next;
	
	}
	
	private List<ArticleCitation> executeEFetch() throws Exception {
		
		String idList = "";

		if( this.eSearcher != null ) {
		
			List<Integer> esearchIds = this.eSearcher.executeESearch(this.startOfPage, this.pageCapacity);
			this.getAllIds().addAll(esearchIds);
			esearchIds.removeAll(this.toSkip);
			while( esearchIds.size() == 0 && this.hasNext() ) {
				this.startOfPage += this.pageCapacity;
				esearchIds = this.eSearcher.executeESearch(this.startOfPage, this.pageCapacity);
				this.getAllIds().addAll(esearchIds);
				esearchIds.removeAll(this.toSkip);
			}
			for(int i = 0;	i < esearchIds.size(); i++) {
				idList += esearchIds.get(i);
				idList += ",";				
			}

		} else {
			
			for(int i = this.startOfPage; 
					i < this.startOfPage + this.pageCapacity && i < this.maxCount; 
					i++) {
				idList += this.ids.get(i);
				idList += ",";				
			}
			
		}	
		
		// trim trailing comma
		if( idList.length() > 0 ) 
			idList = idList.substring(0, idList.length()-1);
		else 
			return null;
		
		logger.info("COUNT: " + (this.startOfPage + this.counter) + ", QUERY: " + baseQueryPrefix + idList + baseQuerySuffix);
		
		URL url = new URL(baseQueryPrefix + idList + baseQuerySuffix);		
        BufferedReader in = new BufferedReader(new InputStreamReader(url.openStream()));

        SAXParser parser = SAXParserFactory.newInstance().newSAXParser();
        InputSource is = new InputSource(in);
        EfetchHandler handler = new EfetchHandler();
        parser.parse(is, handler);
				
		return handler.getArticles();

	}


}
