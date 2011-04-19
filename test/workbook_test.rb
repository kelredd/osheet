require "test/helper"
require 'osheet/workbook'
require 'test/mixins'

module Osheet
  class WorkbookTest < Test::Unit::TestCase

    context "Osheet::Workbook" do
      subject { Workbook.new }

      should_have_readers :styles, :templates
      should_have_instance_methods :title, :style, :template, :attributes, :use

      should_hm(Workbook, :worksheets, Worksheet)

      should "set it's defaults" do
        assert_equal nil, subject.send(:get_ivar, "title")
        assert_equal [], subject.worksheets
        assert_equal StyleSet.new, subject.styles
        assert_equal TemplateSet.new, subject.templates
      end

      context "that has some columns and rows" do
        subject do
          Workbook.new {
            title "The Poo"

            worksheet {
              name "Poo!"

              column

              row {
                cell {
                  format  :number
                  data    1
                }
              }
            }
          }
        end

        should "set it's title" do
          assert_equal "The Poo", subject.send(:get_ivar, "title")
        end

        should "know it's title" do
          subject.title(false)
          assert_equal false, subject.title
          subject.title('la')
          assert_equal 'la', subject.title
          subject.title(nil)
          assert_equal 'la', subject.title
        end

        should "set it's worksheets" do
          worksheets = subject.send(:get_ivar, "worksheets")
          assert_equal 1, worksheets.size
          assert_kind_of Worksheet, worksheets.first
        end

        should "not allow multiple worksheets with the same name" do
          assert_raises ArgumentError do
            Workbook.new {
              title "should fail"

              worksheet { name "awesome" }
              worksheet { name "awesome" }
            }
          end
          assert_nothing_raised do
            Workbook.new {
              title "should not fail"

              worksheet { name "awesome" }
              worksheet { name "awesome1" }
            }
          end
        end

        should "know it's attribute(s)" do
          [:title].each do |a|
            assert subject.attributes.has_key?(a)
          end
          assert_equal "The Poo", subject.attributes[:title]
        end
      end

      context "that defines styles" do
        subject do
          Workbook.new {
            style('.test')
            style('.test.awesome')
          }
        end

        should "add them to it's styles" do
          assert_equal 2, subject.styles.size
          assert_equal 1, subject.styles.first.selectors.size
          assert_equal '.test', subject.styles.first.selectors.first
          assert_equal 1, subject.styles.last.selectors.size
          assert_equal '.test.awesome', subject.styles.last.selectors.first
        end
      end

      context "that defines templates" do
        subject do
          Workbook.new {
            template(:column, :yo) { |color|
              width 200
              meta(:color => color)
            }
            template(:row, :yo_yo) {
              height 500
            }
            template(:worksheet, :go) {
              column(:yo, 'blue')
              row(:yo_yo)
            }
          }
        end

        should "add them to it's templates" do
          assert subject.templates
          assert_kind_of TemplateSet, subject.templates
          assert_equal 3, subject.templates.keys.size
          assert_kind_of Template, subject.templates.get('column', 'yo')
          assert_kind_of Template, subject.templates.get('row', 'yo_yo')
          assert_kind_of Template, subject.templates.get('worksheet', 'go')

          subject.worksheet(:go)
          assert_equal 1, subject.worksheets.size
          assert_equal 'blue', subject.worksheets.first.columns.first.meta[:color]
          assert_equal 500, subject.worksheets.first.rows.first.attributes[:height]
        end
      end

    end

  end

  # class WorkbookScopt < Test::Unit::TestCase
  #   context "a workbook defined among instance variable" do
  #     @title =
  #   end
  # end

  class WorkbookMixins < Test::Unit::TestCase
    context "a workbook w/ mixins" do
      subject do
        Workbook.new {
          use StyledMixin
          use TemplatedMixin
        }
      end

      should "add the mixin styles to it's styles" do
        assert_equal 2, subject.styles.size
        assert_equal 1, subject.styles.first.selectors.size
        assert_equal '.test', subject.styles.first.selectors.first
        assert_equal 1, subject.styles.last.selectors.size
        assert_equal '.test.awesome', subject.styles.last.selectors.first
      end

      should "add the mixin templates to it's templates" do
        assert subject.templates
        assert_kind_of TemplateSet, subject.templates
        assert_equal 3, subject.templates.keys.size
        assert_kind_of Template, subject.templates.get('column', 'yo')
        assert_kind_of Template, subject.templates.get('row', 'yo_yo')
        assert_kind_of Template, subject.templates.get('worksheet', 'go')

        subject.worksheet(:go)
        assert_equal 1, subject.worksheets.size
        assert_equal 'blue', subject.worksheets.first.columns.first.meta[:color]
        assert_equal 500, subject.worksheets.first.rows.first.attributes[:height]
      end

    end
  end

  class WorkbookWriter < Test::Unit::TestCase
    context "a workbook" do
      subject do
        Workbook.new {
          style('.test')
          style('.test.awesome')
        }
      end

      should_have_instance_method :writer, :to_data, :to_file

      should "provide a writer for itself" do
        writer = subject.writer
        assert writer
        assert_kind_of XmlssWriter::Base, writer
      end

    end
  end

end
