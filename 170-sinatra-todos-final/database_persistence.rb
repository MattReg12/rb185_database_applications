require 'pg'

class DatabasePersistence
  def initialize(logger)
    @db = if Sinatra::Base.production?
      PG.connect(ENV['DATABASE_URL'])
    else
      PG.connect(dbname: "todos")
    end
    @logger = logger
  end

  def query(statement, *params)
    p params
    @logger.info "#{statement}: #{params}"
    @db.exec_params statement, params
  end

  def all_lists
    sql = 'SELECT * FROM lists;'
    result = query(sql)

    result.map do |tuple|
      {id: tuple['id'], name: tuple['name'], todos: todos_in_list(tuple['id'])}
    end
  end

  def create_new_list(list_name)
    sql = 'INSERT INTO lists (name) VALUES ($1)'
    query(sql, list_name)
  end

  def delete_todo_from_list(todo_id)
    sql = 'DELETE FROM todos WHERE id = $1'
    query(sql, todo_id)
  end

  def delete_list(id)
    sql = 'DELETE FROM lists WHERE id = $1'
    sql_dos = 'DELETE FROM todos WHERE list_id = $1'
    query(sql, id)
    query(sql_dos, id)
  end

  def find_list(id)
    sql = "SELECT * FROM lists WHERE id = $1"
    result = query(sql, id)
    tuple = result.first
    {id: tuple['id'], name: tuple['name'], todos: todos_in_list(id)}
  end

  def log_error(error)
    # @session[:error_message] = error
  end

  def log_success(success)
    # @session[:success_message] = success
  end

  def update_todo_status(list_id, todo_id, new_status)
    sql = 'UPDATE todos SET completed = $1 WHERE id = $2'
    query(sql, new_status, todo_id)
  end

  def mark_all_todos_as_completed(list_id)
    sql = 'UPDATE todos SET completed = true WHERE list_id = $1'
    query(sql, list_id)
  end

  def update_list_name(id, list_name)
    sql = 'UPDATE lists SET name = $1 WHERE id = $2'
    query(sql, list_name, id)
  end

  def create_new_todo(list_id, todo_name)
    sql = 'INSERT INTO todos (list_id, name) VALUES ($1, $2)'
    query(sql, list_id, todo_name)
  end

  def disconnect
    @db.close
  end

  private

  def todos_in_list(list_id)
    sql = "SELECT * FROM todos t WHERE list_id = $1"
    result = query(sql, list_id)

    result.map do |tuple|
      {id: tuple['id'].to_i, name: tuple['name'], completed: convert_to_bool(tuple['completed'])}
    end
  end

  def convert_to_bool(string)
    string == 't'
  end
end
