package edu.isi.bmkeg.lapdf.dao;

import java.io.File;

import edu.isi.bmkeg.ftd.model.FTD;
import edu.isi.bmkeg.ftd.model.FTDRuleSet;
import edu.isi.bmkeg.lapdf.model.LapdfDocument;
import edu.isi.bmkeg.vpdmf.dao.CoreDao;

/**
 * Defines the interface to a Data Access Object that manage the data persistent
 * storage. A Spring bean implementing this interface can be injected in other
 * Spring beans.
 */
public interface LAPDFTextDao {

	public CoreDao getCoreDao();
	
	public void init(String login, String password, String uri, String workingDirectory) throws Exception;
	
	void insertLapdfDocument(LapdfDocument doc, File pdf, String text)
			throws Exception;

	FTD runRuleSetOnFtd(FTD ftd, FTDRuleSet ftdRuleSet) 
			throws Exception;	

}