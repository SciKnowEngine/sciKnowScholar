package edu.isi.bmkeg.digitalLibrary.bin;

import java.io.File;

import org.apache.log4j.Logger;
import org.kohsuke.args4j.CmdLineException;
import org.kohsuke.args4j.CmdLineParser;
import org.kohsuke.args4j.Option;

import edu.isi.bmkeg.digitalLibrary.bin.RemoveArticleCitationFromCorpus.Options;
import edu.isi.bmkeg.utils.Converters;

public class SetSwfToolsBinDirectory {
	
	public static class Options {

		@Option(name = "-swfToolsBin", usage = "Directory for swftools bin directory", required = true, metaVar = "DIR")
		public File dir;

		@Option(name = "-wd", usage = "Working Directory ", required = true, metaVar = "WD")
		public File wd;
		
	}
	
	private static Logger logger = Logger.getLogger(SetSwfToolsBinDirectory.class);
	
	/**
	 * @param args
	 */
	public static void main(String[] args) throws Exception {

		Options options = new Options();
		
		CmdLineParser parser = new CmdLineParser(options);

		try {
			
			parser.parseArgument(args);
		
		} catch (CmdLineException e) {
			
			System.err.println(e.getMessage());
			System.err.print("Arguments: ");
			parser.printSingleLineUsage(System.err);
			System.err.println("\n\n Options: \n");
			parser.printUsage(System.err);
			System.exit(-1);
		}

		if( !options.dir.exists() ) {
			System.err.print("Arguments: ");
			parser.printSingleLineUsage(System.err);
			System.err.println("\n\n Options: \n");
			parser.printUsage(System.err);
			System.exit(-1);
		}
			
		Converters.writeAppDirectory("swftools", options.dir, options.wd);
		
	}

}
