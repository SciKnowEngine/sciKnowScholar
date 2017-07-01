package edu.isi.bmkeg.digitalLibrary.bin;

import java.io.File;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;

import org.apache.log4j.Logger;
import org.kohsuke.args4j.CmdLineException;
import org.kohsuke.args4j.CmdLineParser;
import org.kohsuke.args4j.Option;

import edu.isi.bmkeg.digitalLibrary.controller.DigitalLibraryEngine;

public class AddPmidEncodedPdfsToCorpus {

	private static Logger logger = Logger.getLogger(AddPmidEncodedPdfsToCorpus.class);

	public static class Options {

		@Option(name = "-pdfs", usage = "Pdfs directory or file", required = true, metaVar = "PDF-DIR-OR-FILE")
		public File pdfFileOrDr;
		
		@Option(name = "-corpus", usage = "Corpus name", required = false, metaVar = "CORPUS")
		public String corpusName;
		
		@Option(name = "-l", usage = "Database login", required = true, metaVar = "LOGIN")
		public String login = "";

		@Option(name = "-p", usage = "Database password", required = true, metaVar = "PASSWD")
		public String password = "";

		@Option(name = "-db", usage = "Database name", required = true, metaVar  = "DBNAME")
		public String dbName = "";

		@Option(name = "-wd", usage = "Working directory", required = true, metaVar  = "WDIR")
		public String workingDirectory = "";
		
	}

	/**
	 * @param args
	 */
	public static void main(String[] args) throws Exception {

		Options options = new Options();
		
		CmdLineParser parser = new CmdLineParser(options);

		DigitalLibraryEngine de = null;

		try {
			
			parser.parseArgument(args);

			if( !options.pdfFileOrDr.exists() ) {
				throw new CmdLineException(parser, options.pdfFileOrDr.getAbsolutePath() + " does not exist.");
			}
			
			de = new DigitalLibraryEngine();
			de.initializeVpdmfDao(options.login, options.password, options.dbName, options.workingDirectory);
			de.getDigLibDao().getCoreDao().connectToDb();
			
			Map<Integer,Long> mapPmidsToVpdmfids = de.insertPmidPdfFileOrDir(options.pdfFileOrDr);
			
			if( options.corpusName != null) {
				List<Integer> ids = new ArrayList<Integer>(mapPmidsToVpdmfids.keySet());
				Collections.sort(ids);
				de.loadArticlesFromPmidListToCorpus(ids, options.corpusName);		
			}
			
		} catch (CmdLineException e) {

			System.err.println(e.getMessage());
			System.err.print("Arguments: ");
			parser.printSingleLineUsage(System.err);
			System.err.println("\n\n Options: \n");
			parser.printUsage(System.err);
			System.exit(-1);
		
		} finally {
			
			de.getDigLibDao().getCoreDao().commitTransaction();
			
		}

	}

}
