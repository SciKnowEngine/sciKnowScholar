package edu.isi.bmkeg.utils.solr;

import java.io.File;
import java.io.IOException;
import java.net.ConnectException;
import java.net.URL;
import java.util.ArrayList;
import java.util.Date;
import java.util.Iterator;
import java.util.List;

import org.apache.commons.httpclient.Credentials;
import org.apache.commons.httpclient.UsernamePasswordCredentials;
import org.apache.commons.httpclient.auth.AuthScope;
import org.apache.log4j.Logger;
import org.apache.solr.client.solrj.SolrQuery;
import org.apache.solr.client.solrj.SolrServerException;
import org.apache.solr.client.solrj.impl.ConcurrentUpdateSolrServer;
import org.apache.solr.client.solrj.impl.XMLResponseParser;
import org.apache.solr.client.solrj.response.QueryResponse;
import org.apache.solr.client.solrj.response.UpdateResponse;
import org.apache.solr.common.SolrDocument;
import org.apache.solr.common.SolrDocumentList;
import org.apache.solr.common.SolrInputDocument;

import edu.isi.bmkeg.utils.xml.XmlBindingTools;
import edu.isi.bmkeg.vpdmf.solr.data.TimedCount;
import edu.isi.bmkeg.vpdmf.solr.data.UploadProcessTiming;

public class SolrApi {

	private static Logger logger = Logger.getLogger(SolrApi.class);
	
	private ConcurrentUpdateSolrServer server;
	
	private UploadProcessTiming eptData;
	private File eptDataFile;
	
	private int skipped;

	private int submitted;	
	private Date dateTimeLastSubmission;

	private long completed; 
	private Date dateTimeStoreLastPolled;

	// TODO: How to represent this in a vpdmf-enabled system?
	//private boolean filterOutNonJournalListRecords;

	private String solrUrl;

	private String login;
	
	private String password;

	// _________________________________________________________________________________
	// Insert / Update
	//
	private int batchStep;

	private ArrayList<SolrInputDocument> batch;

	
	// _________________________________________________________________________________
	// Query
	//
	private int start; 

	private int max;

	private long queryHitCount;
	
	private static int defaultMaxHits = 20000000;
	
	// _________________________________________________________________________________
	// Server
	//

	public SolrApi(String solrUrl, String login, String password, int batchStep, File dataFile) throws Exception {

		this.skipped = 0;
		this.completed = 0;
		this.submitted = 0;

		this.solrUrl = solrUrl;
		this.login = login;
		this.password = password;
		
		this.batchStep = batchStep;
		this.max = SolrApi.defaultMaxHits;

		eptData = new UploadProcessTiming();
		eptDataFile = dataFile;

		this.initializeServer();
		
	}
	
	private void initializeServer() throws Exception {

		server = new ConcurrentUpdateSolrServer(this.solrUrl, 10000, 1);

		// socket read timeout
		server.setSoTimeout(10000000);
		server.setConnectionTimeout(1000000);
		
		// defaults to 0. > 1 not recommended.
		//server.setMaxRetries(1);

		// binary parser is used by default
		server.setParser(new XMLResponseParser());

		// allowCompression defaults to false.
		// Server side must support gzip or deflate for this to have any effect.
		//server.setAllowCompression(true);

		batch = new ArrayList<SolrInputDocument>(batchStep);
		
		//set username and password
		URL u = new URL(this.solrUrl);
		String host = u.getHost();
		int port = u.getPort();
		Credentials creds = new UsernamePasswordCredentials(login,password);
		//server.getHttpClient().getParams().setAuthenticationPreemptive(true);
		//server.getHttpClient().getState().setCredentials(
		//		new AuthScope(host, port, AuthScope.ANY_REALM), 
		//		creds);

		this.completed = this.pollStore();

	}

	public void finalCommit() throws Exception {
		
		if(!isBatchEmpty()){
			commitDocsToStore();
		}
	
	} 

	
	public void close() throws Exception {
		
		if(!isBatchEmpty()){
			commitDocsToStore();
		}

		logger.info( submitted + " documents added to " + solrUrl );
		logger.info( skipped + " skipped" );
		
		if( this.eptDataFile != null) {
			XmlBindingTools.saveAsXml(this.eptData, this.eptDataFile);
		}
	
	} 

	private boolean isBatchEmpty(){
		
		if(batch.isEmpty()) 
			return true;
		
		return false;

	}

	public boolean checkIfServerIsOn() {
		
		SolrQuery q = new SolrQuery("test:test");
		q.setStart(start);
		q.setRows(new Integer(max));
		QueryResponse rsp = null;
		
		try {
			rsp = server.query( q );			
		} catch (SolrServerException e) {
	
			if( e.getCause() instanceof ConnectException)  {
				return false;
			} else {
				return true;				 
			}
				
		}
		
		return false;

	}
	
	public void skipDoc(String id) {
		
		this.skipped++;	

		logger.info("Skipped: " + id );
		
	}
	
	public void addDocToStore(SolrInputDocument doc) throws SolrServerException, IOException {

		if (batch.size() < batchStep ) {

			batch.add(doc);

		} else	{
		
			this.commitDocsToStore();
			batch.add(doc);
		
		}
	
	}

	public void rollback() throws SolrServerException, IOException {
		
		UpdateResponse u = server.rollback();
	
	}

	
	public void commitDocsToStore() throws SolrServerException, IOException {
	
		submitted += batch.size();

		logger.info("Added this run: " + submitted + ", total: " + completed);
		
		//server.add( batch.iterator() );
		server.commit(true, true);
		batch.clear();
		
		this.dateTimeLastSubmission = new Date();
		
		TimedCount tc = new TimedCount();
		tc.setCount(submitted);
		tc.setTime(this.dateTimeLastSubmission);
		
		this.eptData.getSubmitted().add(tc);
	
	}
	
	public int deleteDocsfromStore(String query) throws SolrServerException, IOException {
		
		logger.info( "Deleting... " + query );

		UpdateResponse r = server.deleteByQuery(query);
		server.commit(true, true);
		int s = r.getStatus();
		
		return s;
	
	}

	public int deleteAllDocsfromStore() throws SolrServerException, IOException {
		
		logger.info( "Deleting... " );

		UpdateResponse r = server.deleteByQuery("*:*");
		server.commit(true, true);
		int s = r.getStatus();
		
		return s;
	
	}
	
	public long pollStore() throws Exception {

		SolrQuery q = new SolrQuery("*:*");
		q.setStart(0);
		q.setRows(new Integer(1));		
		QueryResponse rsp = server.query( q );

		this.dateTimeStoreLastPolled = new Date();
		long count = rsp.getResults().getNumFound();
		this.completed = count;
		
		TimedCount tc = new TimedCount();
		tc.setCount(count);
		tc.setTime(this.dateTimeStoreLastPolled);
		this.eptData.getPolled().add(tc);
		
		q = null;
		rsp = null;
		
		return count;
			
	}	
	
	
	
}
