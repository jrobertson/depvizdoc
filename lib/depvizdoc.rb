#!/usr/bin/env ruby

# file: depvizdoc.rb


require 'depviz'
require 'martile'
require 'rdiscount'


module RegGem

  def self.register()
'
hkey_gems
  doctype
    depvizdoc
      require depvizdoc
      class DepVizDoc
      media_type html
'      
  end
end


class DepVizDoc < DepViz

  def initialize(s='', root: 'platform', 
                 style: default_stylesheet(), path: '.', debug: false)
    
    @style, @root, @debug, @path = style, root, debug, path
    @header = "
<?polyrex schema='items[type]/item[label, url]' delimiter =' # '?>
type: digraph

    "
    build(s)
  end
  
  def build(s)

    return if s.empty?    
    
    lines = s.lines
    lines.shift if lines.first =~ /^<\?depvizdoc\b/

    puts 'DepVizDoc::initialize before DependencyBuilder' if @debug
    @s = tree = DependencyBuilder.new(lines.join).to_s
    puts 'master @s: ' + @s.inspect if @debug
    puts 'DepVizDoc::initialize after DependencyBuilder' if @debug
    
    s2 = tree.lines.map do |line|
      x = line.chomp
      "%s # %s.html" % [x, x[/\w+$/]]
    end.join("\n")
    
    
    s = @root ? (@root + "\n" + s2.lines.map {|x| '  ' + x}.join) : s2
    
    puts 'DepVizDoc::initialize before PxGraphViz' if @debug
    @pxg = PxGraphViz.new(@header + s, style: @style)
    puts 'DepVizDoc::initialize after PxGraphViz' if @debug
    

    
  end

  def render(path=@path)
    # generate each HTML file
    items = @s.lines.flatten.map {|x| x.chomp.lstrip }.uniq
    
    FileUtils.mkdir_p File.join(path, 'svg')
    
    items.each do |name|
      
      puts 'DepVizDoc::initialize name: ' + name.inspect if @debug
      
      # generate the dependency chart      
      File.write File.join(path, 'svg', name + '_dep.svg'), 
          self.item(name).dependencies.to_svg
      
      rdep = self.item(name).reverse_dependencies
      # generate the reverse dependency chart

      md = "
# #{name}      

## Dependencies

![](#{File.join(path, 'svg', name + '_dep.svg')})

## Reverse dependencies

"

      md << if rdep then
        File.write File.join(path, 'svg', name + '_rdep.svg'), rdep.to_svg      
        "![](%s)" % File.join(path, 'svg', name + '_rdep.svg')
      else
        'none'
      end    

      html = RDiscount.new(Martile.new(md).to_s).to_html
      File.write File.join(path, name + '.html'), html
      
    end    
    
    filepath = File.join(path, 'chart.svg')
    File.write filepath, self.to_svg
    
    'saved to ' + filepath
  end
  
  
end
