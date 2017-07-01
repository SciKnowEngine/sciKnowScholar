package edu.isi.bmkeg.digitalLibrary.bin;

import static org.junit.Assert.assertEquals;

import java.io.File;
import java.sql.SQLException;
import java.util.ArrayList;

import org.junit.After;
import org.junit.Before;
import org.junit.Ignore;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.context.ApplicationContext;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import edu.isi.bmkeg.uml.model.UMLmodel;
import edu.isi.bmkeg.utils.springContext.AppContext;
import edu.isi.bmkeg.utils.springContext.BmkegProperties;
import edu.isi.bmkeg.vpdmf.controller.VPDMfKnowledgeBaseBuilder;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(locations={ "/edu/isi/bmkeg/digitalLibrary/appCtx-VPDMfTest.xml"})
public class ImportMedlineDirectorySmallTest {
	
	ApplicationContext ctx;
	
	String login, password, dbUrl;
	File archiveFile, bz2File, dir;
	VPDMfKnowledgeBaseBuilder builder;
	
	@Before
	public void setUp() throws Exception {
		
		ctx = AppContext.getApplicationContext();
		BmkegProperties prop = (BmkegProperties) ctx.getBean("bmkegProperties");

		login = prop.getDbUser();
		password = prop.getDbPassword();
		dbUrl = prop.getDbUrl();
		
		int l = dbUrl.lastIndexOf("/");
		if (l != -1)
			dbUrl = dbUrl.substring(l + 1, dbUrl.length());
	
		archiveFile = ctx.getResource(
				"classpath:edu/isi/bmkeg/digitalLibrary/digitalLibrary-mysql.zip").getFile();
		bz2File = ctx.getResource(
				"classpath:edu/isi/bmkeg/digitalLibrary/medline-small/medline_small1.xml").getFile();
		dir = bz2File.getParentFile();
		
		builder = new VPDMfKnowledgeBaseBuilder(archiveFile, 
				login, password, dbUrl); 
		
		try {
			
			builder.destroyDatabase(dbUrl);
	
		} catch (SQLException sqlE) {		
			
			// Gully: Make sure that this runs, avoid silly issues.
			if( !sqlE.getMessage().contains("database doesn't exist") ) {
				sqlE.printStackTrace();
			}
			
		}
		
		builder.buildDatabaseFromArchive();
		
	}

	@After
	public void tearDown() throws Exception {
		
	//	builder.destroyDatabase(dbUrl);
		
	}
	
	@Test
	public final void testRunExecWithFullPaths() throws Exception {
				
		String[] args = new String[] { 
				dir.getPath(), login, password, dbUrl
				};

		ImportMedlineDirectory.main(args);
				
	}
		
}

