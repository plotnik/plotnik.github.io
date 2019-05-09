// Проследить линки на js-файлы во всех html-файлах

@Grab(group='org.ccil.cowan.tagsoup',
      module='tagsoup', version='1.2.1' )

class JsLinks {      
	def tagsoupParser = new org.ccil.cowan.tagsoup.Parser()
	def slurper = new XmlSlurper(tagsoupParser)
	
	void processRoot(dir) {
		dir.eachFileMatch(~/.*\.html/) { file ->
			processHtml(file)
		}
		dir.eachDir { d ->
			if (d.name!='node_modules') {
				processDir(d)
			}
		}
	}
	
	void processDir(dir) {
		dir.eachFileMatch(~/.*\.html/) { file ->
			processHtml(file)
		}
		dir.eachDir { d ->
			processDir(d)
		}
	}
	
	void processHtml(file) {
		println "--- ${file.path}"
		def response = slurper.parseText(file.text)
		def jsLinks = response.'**'.findAll { node -> node.name() == 'script' }*.@src
		println jsLinks
	}
}

new JsLinks().processRoot(new File('.'))
	
