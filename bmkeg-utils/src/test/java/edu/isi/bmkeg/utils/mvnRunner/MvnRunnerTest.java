package edu.isi.bmkeg.utils.mvnRunner;

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

public class MvnRunnerTest extends TestCase {
	
	@Before
	public void setUp() throws Exception {
		LocalMavenInstall.installMavenLocally();
	}

	@After
	public void tearDown() throws Exception {
		LocalMavenInstall.removeLocalMaven();
	}

	@Test
	public void testRunMaven() throws Exception {

		System.out.print(LocalMavenInstall.runMavenCommand("-version"));
	
	}

	@Test
	public void testInstallMaven() throws Exception {

		String[] args = new String[] { 
				"-i"
				};
		
		LocalMavenInstall.main(args);
	
	}	
	
}
