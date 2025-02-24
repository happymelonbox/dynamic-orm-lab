require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

    def self.table_name
        self.to_s.downcase.pluralize
         # checked with pry
    end

    def self.column_names
        # DB[:conn].results_as_hash = true

        sql = "PRAGMA table_info('#{self.table_name}')"
        table_info = DB[:conn].execute(sql)
        column_names = []

        table_info.each do |column|
            column_names << column["name"]
        end
        column_names.compact
         # checked with pry
    end

    def initialize(options={})
        options.each do |property, value|
            self.send("#{property}=", value)
        end
    end

    def table_name_for_insert
        # checked with pry
        self.class.table_name
    end

    def col_names_for_insert
        # checked with pry
        new_cols = self.class.column_names.delete_if {|column_name| column_name == "id"}
        new_cols.join(", ")
    end

    def values_for_insert
        values = []
        self.class.column_names.each do |col_name|
            values << "'#{send(col_name)}'" unless send(col_name).nil?
        end
        values.join(", ")
         # checked with pry
    end

    def save
        sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
        DB[:conn].execute(sql)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
    end

    def self.find_by_name(name)
        sql = "SELECT * FROM #{self.table_name} WHERE name = ?"
        DB[:conn].execute(sql, name)
    end

    def self.find_by(hash)
        sql = "SELECT * FROM #{self.table_name} WHERE #{hash.keys[0].to_s} = '#{hash.values[0]}'"
        DB[:conn].execute(sql)
    end
end