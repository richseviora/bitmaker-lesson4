# Helper Method to format result as currency (two digit precision, trailing zeroes)
def format_as_currency(input)
  '%0.2f' % input
end

class Tax
  #This method returns boolean value indicating whether the item provided has sales tax applied.
  def self.sales_tax_applicable?(item_name = '')
    input_name = item_name.downcase
    case
      when input_name.include?('book')
        return FALSE
      when input_name.include?('chocolate')
        return FALSE
      when input_name.include?('pills')
        return FALSE
      else
        return TRUE
    end
  end

  #This method returns boolean value indicating whether the item provided has import duties.
  def self.import_duty_applicable?(item_name = '')
    input_name = item_name.downcase
    return input_name.include?('imported') ? TRUE : FALSE
  end

  # This method returns the sales tax amount for the tax class.
  def self.sales_tax_amount
    return 0.1
  end

  # This method returns the import tax amount for the tax class.
  def self.import_tax_amount
    return 0.05
  end

end


class LineItem
  def initialize(quantity, item, price)
    @quantity = quantity.to_i
    @item = item
    @price = price.to_f
  end

  # This method returns the per item sales tax as a numeric representation of the tax rate (1 = 100%)
  def sales_tax
    total_tax_percent = 0
    if Tax.sales_tax_applicable?(@item)
      total_tax_percent += Tax.sales_tax_amount
    end
    if Tax.import_duty_applicable?(@item)
      total_tax_percent += Tax.import_tax_amount
    end
    total_tax_percent.round(2)
  end

  # This method returns the sales tax total of the line.
  def line_item_sales_tax_total

    ((pre_tax_total * 20).ceil.to_f / 20.0).round(2)
  end

  def pre_tax_total
    @quantity * sales_tax * @price
  end

  # This method returns the total cost of the line.
  def line_total
    (@quantity * @price + line_item_sales_tax_total).round(2)
  end

  # This method returns the description of the line for output on the receipt.
  def line_description
    "#{@quantity} #{@item}: #{format_as_currency(line_total)}"
  end
end

# This class is the input group object. It handles transforming the inputs into line items, and summarizes the input.
class Input
  def initialize
    @line_items = []
  end

  # This method handles the input and adds them to the line items group.
  def add_line_item_from_string(input_line)
    parsed_line = /(?<quantity>\d+) (?<item>.+) at (?<price>\d*\.\d{2})?/.match(input_line)
    new_line_item = LineItem.new(parsed_line['quantity'],parsed_line['item'],parsed_line['price'])
    @line_items << new_line_item
  end

  def total
    result = 0
    @line_items.each {|line_item| result += line_item.line_total}
    result.round(2)
  end

  def sales_tax_total
    result = 0
    @line_items.each {|line_item| result += line_item.line_item_sales_tax_total}
    result.round(2)
  end

  def describe_line_items
    @line_items.each {|line_item| puts line_item.line_description}
  end

  def describe_input
    describe_line_items
    puts "Sales Taxes: #{format_as_currency(sales_tax_total)}"
    puts "Total: #{format_as_currency(total)}"
  end
end

class ReceiptHandler
  def initialize(filename)
    @filename = filename
    @inputs = []
  end

  def read_receipts
    input_file = File.new(@filename)
    input_started = FALSE
    # Do this until we're done reading groups.
    until input_file.eof?
      input_group_end = FALSE # Telling us that the input_group has not ended yet.
      new_input = Input.new
      @inputs << new_input

      until input_group_end or input_file.eof? # Stop processing a group once we're done with the file.
        input_line = input_file.readline
        case classify_file_line(input_line)
          when :new_input
            if input_started
              input_group_end = TRUE
            else
              input_started = TRUE
            end
          when :line_item
            new_input.add_line_item_from_string(input_line)
          else
        end
      end
    end
  end

  def output_results
    count = 1
    @inputs.each do |input|
      puts "Output: #{count}"
      input.describe_input
      count += 1
      puts
    end
  end

  def classify_file_line(input_line)
    case
      when input_line.length <= 1
        return :empty
      when input_line.include?('Input')
        return :new_input
      else
        return :line_item
    end
  end
end

handle_receipt = ReceiptHandler.new('exercise4-3input.txt')
handle_receipt.read_receipts
handle_receipt.output_results