begin
  require 'mediacloth'
rescue LoadError
  require 'rubygems'
  require 'mediacloth'
end

class MediaKiller
  def initialize(target)
    case target
    when :markdown
      # ok
    else
      raise "unsupported target format: #{target}"
    end
    
    @generator_class = TARGETS[target]
    
    # default link mapper just passes through
    @link_mapper = lambda {|text, link| return text, link}
  end
  
  attr_accessor :link_mapper
  
  def convert(content)
    @parser = MediaWikiParser.new
    @parser.lexer = MediaWikiLexer.new
    ast = @parser.parse(content)
    
    generator = @generator_class.new
    generator.link_mapper = @link_mapper
    # this chomping is gross, but the mediacloth AST doesn't
    # reflect structure well, so we toss \n around a lot
    generator.parse(ast).chomp.chomp
  end
  
  class MediaWikiMarkdownGenerator
    attr_accessor :link_mapper
    
    def parse(ast)
      case ast
      when InternalLinkAST
        parse_internal_link(ast)
      when InternalLinkItemAST
        parse_internal_link_item(ast)
      when LinkAST
        parse_link(ast)
      when ListAST
        parse_list(ast)
      when ListItemAST
        parse_list_item(ast)
      when ParagraphAST
        parse_paragraph(ast)
      when PreformattedAST
        parse_preformatted(ast)
      when ResourceLinkAST
        parse_resource_link(ast)
      when SectionAST
        parse_section(ast)
      when TextAST
        parse_text(ast)
      when WikiAST
        parse_wiki(ast)
        
      # this comes last, because it's a superclass of several others
      when FormattedAST
        parse_formatted(ast)
      else
        raise "unknown AST element: #{ast}"
      end
    end
    
    def parse_formatted(ast)
      case ast.formatting
      when :Bold
        "**#{parse_wiki(ast)}**"
      when :Italic
        "*#{parse_wiki(ast)}*"
      else
        raise "unsupported formatting: #{ast.formatting} in #{ast}"
      end
    end
    
    def parse_internal_link(ast)
      # is there ever more than one child?
      link = ast.locator
      text = ast.children.empty? ? link : parse(ast.children.first)
      mapped_text, mapped_link =
        link_mapper.call(text, link)
      "[#{mapped_text}](#{mapped_link})"
    end
    
    def parse_internal_link_item(ast)
      # do these do anything other than aggregate a child?
      parse(ast.children.first)
    end
    
    def parse_link(ast)
      # is there ever more than one child?
      link = ast.url
      text = ast.children.empty? ? link : parse(ast.children.first)
      mapped_text, mapped_link =
        link_mapper.call(text, link)
      "[#{mapped_text}](#{mapped_link})"
    end
    
    def parse_list(ast)
      case ast.list_type
      when :Bulleted
        ast.children.map do |child|
          "* #{parse(child)}"
        end.join + "\n"
      when :Numbered
        index = 0
        ast.children.map do |child|
          index+=1
          "#{index}. #{parse(child)}"
        end.join + "\n"
      else
        raise "unsupported list format: #{ast.list_type} in #{ast}"
      end
    end
    
    def parse_list_item(ast)
      # do list items do anything but aggregate a child?
      parse(ast.children.first)
    end
    
    def parse_paragraph(ast)
      parse_wiki(ast) + "\n\n"
    end
    
    def parse_preformatted(ast)
      '> ' + ast.contents
    end
    
    def parse_resource_link(ast)
      case ast.prefix
      when "Image"
        # size not supported
        link = ast.locator
        if ast.children.empty?
          text = link
        else
          case ast.children.size
          when 1
            text = parse(ast.children.first)
          when 2
            warn "image size is not supported"
            text = parse(ast.children[1])
          else
            raise "unknown size of image resource link children: #{ast.inspect}"
          end
        end
        mapped_text, mapped_link = link_mapper.call(text, link)
        "![#{mapped_text}](#{mapped_link})"
      else
        raise "unsupported resource link: #{ast.inspect}"
      end
    end
    
    def parse_section(ast)
      content = ast.children.map {|child| parse(child)}.join
      length = content.length
      # prepend appropriate number of hash signs plus a space
      "#{'#' * (ast.level - 1)} #{content}\n"
    end
    
    def parse_text(ast)
      ast.contents
    end
    
    def parse_wiki(ast)
      ast.children.map do |child|
        parse(child)
      end.join
    end
  end
  
  TARGETS = {
    :markdown => MediaWikiMarkdownGenerator
  }
end