package edu.isi.bmkeg.utils;

import static org.junit.Assert.assertTrue;

import java.io.File;
import java.util.Map;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import com.google.common.io.Files;

import edu.isi.bmkeg.utils.mvnRunner.LocalMavenInstall;

public class ConvertersTest {

	@Before
	public void setUp() throws Exception {
	}

	@After
	public void tearDown() throws Exception {
	}

	@Test
	public void testGetEntryFromZippedJarFile() throws Exception {
	
		String mvnPath = ClassLoader.getSystemResource("edu/isi/bmkeg/utils/mvnRunner/" + LocalMavenInstall.MVN_FILE).getFile();
		String libPath = mvnPath + "!/" + LocalMavenInstall.MVN_VERSION + "/lib/aether-api-1.13.1.jar";
		File f = new File(libPath);
		
		File tempUnzippedDirectory = Files.createTempDir();
		tempUnzippedDirectory.deleteOnExit();
		
		Map<String, File> toClean = Converters.unzipIt(f, tempUnzippedDirectory); 
		toClean.put(tempUnzippedDirectory.getPath(), tempUnzippedDirectory);
		
		File uzf = new File(tempUnzippedDirectory + "/org");
		
		assertTrue(uzf.exists());

		Converters.recursivelyDeleteFiles(tempUnzippedDirectory);
		
	}

}
