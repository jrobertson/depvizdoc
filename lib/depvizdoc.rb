#!/usr/bin/env ruby

# file: depvizdoc.rb


require 'depviz'
require 'martile'
require 'rdiscount'


class DepVizDoc < DepViz

  def initialize(s='', root: 'platform', 
                 style: default_stylesheet(), path: '.', debug: false)
    
    @style, @root, @debug = style, root, debug
    @header = "
<?polyrex schema='items[type]/item[label, url]' delimiter =' # '?>
type: digraph

    "
    
    return if s.empty?

    puts 'DepVizDoc::initialize before DependencyBuilder' if @debug
    @s = tree = DependencyBuilder.new(s).to_s
    puts 'master @s: ' + @s.inspect if @debug
    puts 'DepVizDoc::initialize after DependencyBuilder' if @debug
    
    s2 = tree.lines.map do |line|
      x = line.chomp
      "%s # %s.html" % [x, x[/\w+$/]]
    end.join("\n")
    
    
    s = root ? (root + "\n" + s2.lines.map {|x| '  ' + x}.join) : s2
    
    puts 'DepVizDoc::initialize before PxGraphViz' if @debug
    @pxg = PxGraphViz.new(@header + s, style: style)
    puts 'DepVizDoc::initialize after PxGraphViz' if @debug
    
    # generate each HTML file
    items = tree.lines.flatten.map {|x| x.chomp.lstrip }.uniq
    
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
      File.write File.join(name + '.html'), html
      
    end

  end
    
end
