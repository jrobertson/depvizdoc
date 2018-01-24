#!/usr/bin/env ruby

# file: depvizdoc.rb


require 'depviz'
require 'martile'
require 'rdiscount'


class DepVizDoc < DepViz

  def initialize(s='', root: 'platform', 
                 style: default_stylesheet(), path: '.')
    
    @style, @root = style, root
    @header = "
<?polyrex schema='items[type]/item[label, url]' delimiter =' # '?>
type: digraph

    "
    
    return if s.empty?
    
    @s = tree = DependencyBuilder.new(s).to_s   
    
    s2 = tree.lines.map do |line|
      x = line.chomp
      "%s # %s.html" % [x, x[/\w+$/]]
    end.join("\n")
    
    
    s = root ? (root + "\n" + s2.lines.map {|x| '  ' + x}.join) : s2

    @pxg = PxGraphViz.new(@header + s, style: style)
    
    # generate each HTML file
    items = tree.lines.flatten.map {|x| x.chomp.lstrip }.uniq
    
    FileUtils.mkdir_p File.join(path, 'svg')
    
    items.each do |item|
      
      # generate the dependency chart      
      File.write File.join(path, 'svg', item + '_dep.svg'), 
          self.item(item).dependencies.to_svg
      
      rdep = self.item(item).reverse_dependencies
      # generate the reverse dependency chart
      
      if rdep then
        File.write File.join(path, 'svg', item + '_rdep.svg'), rdep.to_svg
      end
      
      md = "
# #{item}      

## Dependencies

![](#{File.join(path, 'svg', item + '_dep.svg')})

## Reverse dependencies

"

      md << if rdep then
        "![](%s)" % File.join(path, 'svg', item + '_rdep.svg')
      else
        'none'
      end    

      html = RDiscount.new(Martile.new(md).to_s).to_html
      File.write File.join(item + '.html'), html
      
    end

  end

end
