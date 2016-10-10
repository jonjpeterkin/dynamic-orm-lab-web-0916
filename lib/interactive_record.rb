require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

	def self.table_name
		self.to_s.downcase.pluralize
	end

	def self.column_names
		sql = "PRAGMA table_info(#{self.table_name})"
		DB[:conn].execute(sql).map {|col| col.fetch("name")}.compact
	end

	def self.find_by_name(name)
		sql = "SELECT * FROM #{table_name} WHERE name = '#{name}'"
		DB[:conn].execute(sql)
	end

	def self.find_by(options = {})	
		sql = "SELECT * FROM #{table_name} WHERE #{options.keys[0]} = '#{options.values[0]}'"
		DB[:conn].execute(sql)
	end


	def initialize(options = {})
		options.each do |property, value|
			send("#{property}=", value)
		end
	end
  
  def table_name_for_insert
  	self.class.table_name
  end

  def col_names_for_insert
  	self.class.column_names.delete_if {|col| col == ("id")}.join(", ")
  end

  def values_for_insert
  	val_ary = self.class.column_names.map do |col| 
  		"'#{send(col)}'" unless col == "id"
  	end
  	val_ary.compact.join(", ")
  end

  def save
  	sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
  	DB[:conn].execute(sql)
  	@id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

end