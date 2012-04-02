package fr.crim.littre.xml;

import java.io.File;
import java.io.FilenameFilter;
import java.util.regex.Pattern;

public class GlobFilter implements  FilenameFilter {
	Pattern pattern;
	public GlobFilter(String glob) {
		if (glob == null) glob="*";
		glob=glob.replaceAll("\\.", "\\\\.").replaceAll("([*?])", ".$1");
		pattern=Pattern.compile(glob);
	}
	public boolean accept(File f, String s) {
		return pattern.matcher(s).matches();
	}
}
