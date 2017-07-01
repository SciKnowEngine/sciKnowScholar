package edu.isi.bmkeg.utils.svn;

import static org.junit.Assert.assertEquals;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.Writer;
import java.net.URL;

import junit.framework.TestCase;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

public class TestSVNEvaluateService extends TestCase {

	private SvnUtils svnUtils = null;
	private File temp, topDir, svnDir;

	private static String LOGIN = "";
	private static String PASSWORD = "";
	
	
	@Before
	public void setUp() throws Exception {
		
		// use 'temp' to locate a file in the local directory, and extrapolate the path
		URL url = ClassLoader.getSystemResource("edu/isi/bmkeg/utils/svn/temp.txt");
		String path = url.getPath();
		topDir = new File(path.substring(0,path.lastIndexOf("/")));
		svnDir = new File(topDir.getPath() + "/svnDir");
		
		if( svnDir.exists() ) {
			svnDir.delete();
		}
		svnDir.mkdir();
			
	}

	@After
	public void tearDown() throws Exception {

	
	}

	@Test
	public void testRunEvaluation() throws Exception {

		if( LOGIN.length() == 0 ) {
			assert(true);
			return;
		}
		
		svnUtils = new SvnUtils(
				"https://hugin.isi.edu:1739/svn/repository/code/utils/trunk/src/main/java",
				LOGIN, 
				PASSWORD, 
				svnDir);

		
		File thisCode = new File(this.svnDir + "/MANIFEST.MF");
		svnUtils.getEntry(
				"META-INF/MANIFEST.MF", 
				thisCode);
		
		long fileSize = thisCode.length();
		
		assertEquals("Manifest file expected to be 39B: ", 39L, fileSize);
		
	}

	@Test
	public void testCheckout() throws Exception {

		if( LOGIN.length() == 0 ) {
			assert(true);
			return;
		}

		long v = svnUtils.checkout();

		File manifest = new File(svnDir.getPath() + "/MANIFEST.MF");
		long fileSize = manifest.length();
		assertEquals("Manifest file expected to be 39B: ", 39L, fileSize);
		
	}

	@Test
	public void testCheckForChanges() throws Exception {

		if( LOGIN.length() == 0 ) {
			assert(true);
			return;
		}

		long v = svnUtils.checkout();
		
		File temp = new File(svnDir.getPath() + "/META-INF/MANIFEST.MF");
		Writer output = new BufferedWriter(new FileWriter(temp));
		try {
			output.write("ARGH");
		} finally {
			output.close();
		}
		
		boolean check = svnUtils.checkForChange();
		assertTrue(check);
		
	}
	
}
