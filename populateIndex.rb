require 'nokogiri'
require 'sqlite3'

doc_file = ARGV.first
file_name = ARGV.first

def createSQLLiteDB
  db = SQLite3::Database.new( "./docSet.dsidx" ) 
  db.execute("CREATE TABLE IF NOT EXISTS searchIndex(id INTEGER PRIMARY KEY, name TEXT, type TEXT, path TEXT);")
  return db
end

def parseFile(filename)
  filepath = "starlingdocs/" + filename
  doc = Nokogiri::HTML(open(filepath))
  header = doc.css("td.titleTableSubTitle")
  
  insert = "INSERT INTO searchIndex VALUES (NULL, '#{header.text}', 'Class', '#{filename}');"
  @db.execute(insert)
  puts insert

  #Add propertes
  doc.css("#summaryTableProperty > tr > .summaryTableSignatureCol > .signatureLink").each do |x|
    if x.parent.parent.attr("class") != "hideInheritedProperty"
      insert = "INSERT INTO searchIndex VALUES (NULL, '#{x.text}', 'Property', '#{filename}#{x.attr('href')}');"
      @db.execute(insert)
      puts "    " + insert
    end
  end

  #Add constants
  doc.css("#summaryTableConstant > tr > .summaryTableSignatureCol > .signatureLink").each do |x|
    if x.parent.parent.attr("class") != "hideInheritedConstant"
      insert = "INSERT INTO searchIndex VALUES (NULL, '#{x.text}', 'Constant', '#{filename}#{x.attr('href')}');"
      @db.execute(insert)
      puts "    " + insert
    end
  end

  #Add methods
  doc.css("#summaryTableMethod > tr > .summaryTableSignatureCol > div > .signatureLink").each do |x|
    if x.parent.parent.parent.attr("class") != "hideInheritedMethod"
      insert = "INSERT INTO searchIndex VALUES (NULL, '#{x.text}', 'Method', '#{filename}#{x.attr('href')}');"
      @db.execute(insert)
      puts "    " + insert
    end
  end

end

@db = createSQLLiteDB

doc = Nokogiri::HTML(ARGF.read)

links = doc.css('a')
links.collect do |item|
  parseFile(item.attr("href"))
end

case doc
when :module then
  puts "CREATE TABLE IF NOT EXISTS searchIndex(id INTEGER PRIMARY KEY, name TEXT, type TEXT, path TEXT);"

  #write_html(doc, file_name)

  mod = doc.css("h3").first.next.next.content
  puts "INSERT INTO searchIndex VALUES (NULL, '#{mod}', 'cl', '#{file_name}');"
  doc.css("#content > .innertube > p > a").each do |x|
    fun = x.attr('name').gsub("'", "")
    puts "INSERT INTO searchIndex VALUES (NULL, '#{mod}:#{fun.sub('-', '/')}', 'func', '#{file_name}##{fun}');"
  end
end