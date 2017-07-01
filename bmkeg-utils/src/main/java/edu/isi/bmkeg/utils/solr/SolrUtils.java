package edu.isi.bmkeg.utils.solr;

import java.io.File;
import java.io.StringReader;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;

import org.apache.log4j.Logger;

import com.google.common.io.Files;

import edu.isi.bmkeg.utils.Converters;
import edu.isi.bmkeg.utils.TextUtils;
import edu.isi.bmkeg.utils.solr.specs.CoreListSpec;
import edu.isi.bmkeg.utils.solr.specs.CoreSpec;
import edu.isi.bmkeg.utils.solr.specs.FieldSpec;
import edu.isi.bmkeg.utils.solr.specs.SchemaSpec;
import edu.isi.bmkeg.utils.solr.specs.SolrSpec;
import edu.isi.bmkeg.utils.superGraph.SuperGraphTraversal;
import edu.isi.bmkeg.utils.xml.XmlBindingTools;

public class SolrUtils {

	private static Logger logger = Logger.getLogger(SolrUtils.class);

	private Map<String, File> cleanUp = new HashMap<String, File>();
	
	// _________________________________________________________________________________
	// Schema
	//
	private File tempConfigDirectory;

	private SchemaSpec schema;


	// _________________________________________________________________________________

	public SchemaSpec getSchema() {
		return schema;
	}

	public void setSchema(SchemaSpec schema) {
		this.schema = schema;
	}

	// _________________________________________________________________________________

	public void buildSolrSpecZip(File solrSchemaZip, String[] views) //, VPDMf top)
			throws Exception {
		
		File confZip = new File(ClassLoader.getSystemResource(
				"edu/isi/bmkeg/vpdmf/solr/conf.zip").getFile());
		tempConfigDirectory = Files.createTempDir();
		tempConfigDirectory.deleteOnExit();
		
		Converters.unzipIt(confZip, tempConfigDirectory);
		
		File schemaFile = new File(tempConfigDirectory.getPath()
				+ "/conf/schema-template.xml");
		String spec = TextUtils.readFileToString(schemaFile);
		spec = spec.replaceAll("[\\t\\n]", "");
		StringReader reader = new StringReader(spec);

		this.setSchema(XmlBindingTools.parseXML(reader, SchemaSpec.class));

		File confDir = new File(tempConfigDirectory.getPath() + "/conf");

		Map<String, File> fileMap = new HashMap<String, File>();

		//SolrSpec solr = this.buildSolrCoresForVPDMf(top, views);

		File solrFile = new File(tempConfigDirectory.getPath() + "/solr.xml");
		//XmlBindingTools.saveAsXml(solr, solrFile);

		this.cleanUp.put(solrFile.getPath(), solrFile);
		fileMap.put("solr.xml", solrFile);

		/*for (int i = 0; i < views.length; i++) {
			String key = views[i];
			ViewDefinition vd = top.getViews().get(key);

			SchemaSpec schema = this.buildSolrSchemaForView(vd);

			File solrSchema = new File(tempConfigDirectory.getPath() + "/"
					+ vd.getName().toLowerCase() + "_schema.xml");

			XmlBindingTools.saveAsXml(schema, solrSchema);

			fileMap.put(vd.getName().toLowerCase() + "/conf/schema.xml",
					solrSchema);
			this.cleanUp.put(solrSchema.getPath(), solrSchema);

			this.addToFileMap(fileMap, confDir, vd.getName().toLowerCase());

		}*/

		Converters.zipIt(fileMap, solrSchemaZip);
		Converters.recursivelyDeleteFiles(tempConfigDirectory);

	}

	private void addToFileMap(Map<String, File> fileMap, File dirToAdd,
			String stem) {

		File[] ff = dirToAdd.listFiles();
		for (int j = 0; j < ff.length; j++) {
			File f = ff[j];
			if (f.getName().equals("schema.xml")) {

				continue;

			} else if (f.isDirectory()) {

				this.addToFileMap(fileMap, f, stem);

			} else {

				String path = f.getPath().substring(
						tempConfigDirectory.getPath().length());
				fileMap.put(stem + path, f);
				this.cleanUp.put(f.getPath(), f);
			}

		}

	}

	// _________________________________________________________________________________


}
