package edu.isi.bmkeg.digitalLibrary.utils;

import java.util.HashMap;
import java.util.Map;

import org.apache.uima.jcas.JCas;
import org.apache.uima.jcas.cas.FSArray;

import bioc.BioCAnnotation;
import bioc.BioCDocument;
import bioc.BioCLocation;
import bioc.BioCNode;
import bioc.BioCPassage;
import bioc.BioCRelation;
import bioc.BioCSentence;
import bioc.type.MapEntry;
import bioc.type.UimaBioCAnnotation;
import bioc.type.UimaBioCDocument;
import bioc.type.UimaBioCLocation;
import bioc.type.UimaBioCNode;
import bioc.type.UimaBioCPassage;
import bioc.type.UimaBioCRelation;
import bioc.type.UimaBioCSentence;

public class BioCUtils {

	public static BioCDocument convertUimaBioCDocument(UimaBioCDocument uiD) {

		BioCDocument d = new BioCDocument();
		d.setInfons(convertInfons(uiD.getInfons()));

		FSArray passages = uiD.getPassages();
		if (passages != null) {
			for (int i = 0; i < passages.size(); i++) {
				UimaBioCPassage uiP = (UimaBioCPassage) passages.get(i);

				BioCPassage p = new BioCPassage();
				p.setInfons(convertInfons(uiP.getInfons()));
				p.setOffset(uiP.getOffset());
				p.setText(uiP.getCoveredText());
				d.addPassage(p);

				FSArray annotations = uiP.getAnnotations();
				if (annotations != null) {
					for (int j = 0; j < annotations.size(); j++) {
						UimaBioCAnnotation uiA = (UimaBioCAnnotation) annotations
								.get(j);

						BioCAnnotation a = new BioCAnnotation();
						a.setInfons(convertInfons(uiA.getInfons()));
						a.setID(uiA.getId());						
						a.setText(uiA.getCoveredText());
						
						p.addAnnotation(a);

						FSArray locations = uiA.getLocations();
						if (locations != null) {
							for (int k = 0; k < locations.size(); k++) {
								UimaBioCLocation uiL = (UimaBioCLocation) locations
										.get(k);

								BioCLocation l = new BioCLocation();
								l.setOffset(uiL.getOffset());
								l.setLength(uiL.getLength());
								a.addLocation(l);

							}
						}

					}
				}

				FSArray relations = uiP.getRelations();
				if (relations != null) {
					for (int j = 0; j < relations.size(); j++) {
						UimaBioCRelation uiR = (UimaBioCRelation) relations
								.get(j);

						BioCRelation r = new BioCRelation();
						r.setID(uiR.getId());
						p.addRelation(r);

						FSArray nodes = uiR.getNodes();
						for (int k = 0; k < nodes.size(); k++) {
							UimaBioCNode uiN = (UimaBioCNode) nodes.get(k);

							BioCNode n = new BioCNode();
							n.setRefid(uiN.getRefid());
							n.setRole(uiN.getRole());
							r.addNode(n);

						}

					}
				}

				/*FSArray sentences = uiP.getSentences();
				if (sentences != null) {
					for (int j = 0; j < sentences.size(); j++) {
						UimaBioCSentence uiS = (UimaBioCSentence) sentences
								.get(j);

						BioCSentence s = new BioCSentence();
						s.setInfons(convertInfons(uiS.getInfons()));
						s.setOffset(uiS.getOffset());
						s.setText(uiS.getCoveredText());
						p.addSentence(s);

					}
				}*/

			}

		}

		return d;

	}

	public static UimaBioCAnnotation convertBioCAnnotation(BioCAnnotation a,
			JCas jcas) {

		UimaBioCAnnotation uiA = new UimaBioCAnnotation(jcas);

		uiA.setInfons(convertInfons(a.getInfons(), jcas));
		uiA.setId(a.getID());
		uiA.setText(a.getText());

		if (a.getLocations() != null) {
			FSArray locations = new FSArray(jcas, a.getLocations().size());
			int count = 0;
			for (BioCLocation l : a.getLocations()) {
				UimaBioCLocation uiL = new UimaBioCLocation(jcas);
				uiL.setOffset(l.getOffset());
				uiL.setLength(l.getLength());
				locations.set(count, uiL);
				count++;
			}
		}

		return uiA;

	}

	public static Map<String, String> convertInfons(FSArray fsArray) {
		Map<String, String> map = new HashMap<String, String>();
		if (fsArray != null) {
			for (int i = 0; i < fsArray.size(); i++) {
				MapEntry me = (MapEntry) fsArray.get(i);
				map.put(me.getKey(), me.getValue());
			}
		}
		return map;
	}

	public static FSArray convertInfons(Map<String, String> infons, JCas jcas) {
		FSArray fsArray = new FSArray(jcas, infons.size());
		int count = 0;
		if (infons != null) {
			for (String key : infons.keySet()) {
				String value = infons.get(key);
				MapEntry me = new MapEntry(jcas);
				me.setKey(key);
				me.setValue(value);
				fsArray.set(count, me);
				count++;
			}
		}
		return fsArray;
	}

}
