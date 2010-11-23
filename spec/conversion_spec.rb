$: << File.join(File.dirname(File.dirname(__FILE__)), 'lib')
require 'mediakiller'

describe "MediaWiki markup" do
  before :each do
    @killer = MediaKiller.new(:markdown)
  end
  
  describe "headers" do
    it "becomes '# ' headers of appropriate depth" do
      @killer.convert("==header==").should == "# header"
      @killer.convert("===header===").should == "## header"
      @killer.convert("====header====").should == "### header"
      @killer.convert("=====header=====").should == "#### header"
      @killer.convert("======header======").should == "##### header"
      @killer.convert("=======header=======").should == "###### header"
    end
  end
  
  describe "preformatted text" do
    it "becomes '> ' prefixed text" do
      @killer.convert(" line1\n line2").should == "> line1\n> line2"
    end
  end
  
  describe "italic text" do
    it "becomes emphasized text" do
      @killer.convert("''text''").should == '*text*'
    end
  end
  
  describe "bold text" do
    it "becomes strong text" do
      @killer.convert("'''text'''").should == '**text**'
    end
  end
  
  describe "unordered bulleted lists" do
    it "remain the same" do
      @killer.convert("* one\n* two").should == "* one\n* two"
    end
  end
  
  describe "ordered bulleted lists" do
    it "become numbered lists" do
      @killer.convert("# one\n# two").should == "1. one\n2. two"
    end
  end
  
  describe "internal links" do
    it "become []() links based on provided mapper" do
      @killer.convert("[[Foo|Bar]]").should == "[Bar](Foo)"
    end
  end
  
  describe "external links" do
    it "becomes []() links based on provided mapper" do
      @killer.convert("http://blog.headius.com").should ==
        "[http://blog.headius.com](http://blog.headius.com)"
      @killer.convert("[http://blog.headius.com blog]").should ==
        "[blog](http://blog.headius.com)"
    end
  end
  
  describe "inline images" do
    it "becomes ![]() images based on provided mapper" do
      @killer.convert("[[Image:something.png|50px|alt text]]").should ==
        "![alt text](something.png)"
    end
  end
  
  describe "code sections" do
    it "becomes backticked sections" do
      pending "mediacloth does not treat <code> separately" do
        @killer.convert('<code>blah</code>').should == '`blah`'
      end
    end
  end
end