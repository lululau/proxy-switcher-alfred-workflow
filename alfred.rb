#!/usr/bin/env ruby

require "delegate"

class String
  def to_argv    
    argv = []
    meta_char_stack = []
    arg = nil
    idx = 0
    while idx < self.size
      char = self[idx]
      top = meta_char_stack.last
      case char
      when %{"}
        case top
        when %{"}
          meta_char_stack.pop
          arg ||= ""
        when %{'}
          (arg ||= "") << char
        when %{\\}
          meta_char_stack.pop
          (arg ||= "") << char
        else
          meta_char_stack << char
        end

      when %{'}
        case top
        when %{"}
          (arg ||= "") << char
        when %{'}
          meta_char_stack.pop  
          arg ||= ""
        else
          meta_char_stack << char
        end

      when %{\\}
        case top
        when %{"}
          meta_char_stack << char
        when %{'}
          (arg ||= "") << char
        when %{\\}
          meta_char_stack.pop
          (arg ||= "") << char
        else
          meta_char_stack << char
        end

      when %{ }
        case top
        when %{"}
          (arg ||= "") << char
        when %{'}
          (arg ||= "") << char
        when %{\\}
          meta_char_stack.pop
          (arg ||= "") << char
        else
          argv << arg if arg
          arg = nil
        end
      else
        if top == %{\\}
          meta_char_stack.pop
        end
        (arg ||= "") << char
      end
      idx += 1
    end
    argv << arg if arg
    argv
  end

end

class MDLS

  module ContentType
    Mail = "com.apple.mail.emlx"
    WebHistory = "com.apple.safari.history"        
  end

  def initialize(filename)
    @filename = filename
    @metadata = `mdls '#{filename}'`
  end

  def [](key)
    m = @metadata.scan(/^#{key}\s*=\s\(\n([^\)]*)\)\n/m)
    if not m.empty?
      multi_values =  m.first.first
      return multi_values.lines.map do |line|
        line[/"([^"]*)"/, 1]
      end
    else
      return @metadata[/^#{key}\s*=\s"([^"]*)"/, 1]
    end
  end

  def content_type
    @content_type ||= self['kMDItemContentType']
  end

  def web_history?
    content_type == ContentType::WebHistory
  end

  def web_title
    @web_title ||= self['kMDItemDisplayName']
  end

  def web_url
    @web_url ||= self['kMDItemURL']
  end

  def mail?
    content_type == ContentType::Mail
  end

  def mail_title
    @mail_title ||= self['kMDItemSubject']
  end

  def mail_authors
    @mail_authors ||= self['kMDItemAuthorEmailAddresses']
  end

  def mail_recipients
    @mail_recipients ||= self['kMDItemRecipientEmailAddresses']
  end
end

class Item
  attr_accessor :attributes, :title, :subtitle, :icon

  def initialize
    @attributes = {}
    @title = ""
    @subtitle = ""
    @icon = {}
  end

  def to_xml
    xml = "<item"
    attributes.each do |name, value|
      xml << " #{name.to_s}=\"#{value}\""
    end
    xml << ">"

    xml << "<title>"
    xml << title
    xml << "</title>"

    xml << "<subtitle>"
    xml << subtitle
    xml << "</subtitle>"

    if icon and not icon.empty?
      xml << "<icon"
      xml << " type=\"#{icon[:type]}\"" if icon[:type]
      xml << ">"
      xml << icon[:text]
      xml << "</icon>"
    end

    xml << "</item>"
  end
end

class FileItem < Item

  class << self
    def create(path)
      case path
      when /\.emlx/
        MailFileItem.new path
      when /\.webhistory/
        WebHistoryFileItem.new path
      else
        new path
      end
    end
  end

  def initialize(path)
    super()
    path.chomp!
    basename = File.basename path
    @attributes[:uid] = path
    @attributes[:arg] = path
    @attributes[:valid] = "yes"
    @attributes[:autocomplete] = basename
    @attributes[:type] = "file"
    @title = basename
    @subtitle = path
    @icon[:type] = "fileicon"
    @icon[:text] = path
  end
end

class MailFileItem < FileItem
  def initialize(path)
    super
    path.chomp!
    mdls = MDLS.new path
    return unless mdls.mail?
    @title = mdls.mail_title
    @subtitle = "Author: %s, Recipient: %s" % [mdls.mail_authors.first, 
      mdls.mail_recipients && mdls.mail_recipients.first]
  end
end

class WebHistoryFileItem < FileItem
  def initialize(path)
    super
    path.chomp!
    mdls = MDLS.new path
    return unless mdls.web_history?
    @title = mdls.web_title
    @subject = mdls.web_url
  end
  
end

class ItemList < DelegateClass(Array)
  def initialize(items=[])
     @items = items
     super items
  end

  def to_xml
    xml = <<-EOF
    <?xml version="1.0"?>
    <items>
    #{@items.map { |item| "    " + item.to_xml }.join("\n") rescue ''}
    </items>
    EOF
  end

  def add_file_item(path)
    @items << FileItem.create(path)
    self
  end

  def add_file_list(paths)
    @items.concat(paths.map { |p| FileItem.create(p) })
    self
  end

  def add_items(lines)
    lines.each do |line|
      if test ?e, line.chomp
        @items << FileItem.create(line)
      else
        item = Item.new
        item.title = line
        @items << item
      end
    end
    self
  end
end
