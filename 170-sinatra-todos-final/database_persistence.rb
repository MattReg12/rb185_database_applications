require 'pg'

class DatabasePersistence
  def initialize(logger)
    @db = PG.connect(dbname: 'todos')
    @logger = logger
  end

  def query(statement, *params)
    @logger.info "#{statement}: #{params}"
    @db.exec_params statement, params
  end

  def all_lists
    sql = 'SELECT * FROM lists;'
    result = query(sql)

    result.map do |tuple|
      {id: tuple['id'], name: tuple['name'], todos: []}
    end
  end

  def create_new_list(list_name)
    # id = next_element_id(@storage.all_lists)
    # @session[:lists] << { id: id, name: list_name, todos: [] }
  end

  def delete_todo_from_list(list_id, todo_id)
    # list = find_list(list_id)
    # list[:todos].reject! { |todo| todo[:id] == todo_id }
  end

  def delete_list(id)
    # @session[:lists].reject! { |list| list[:id] == id }
  end

  def find_list(id)
    sql = "SELECT * FROM lists WHERE id = $1"
    result = query(sql, id)
    tuple = result.first
    {id: tuple['id'], name: tuple['name'], todos: todos_in_list(id)}
  end

  def todos_in_list(list_id)
    sql = "SELECT * FROM lists l JOIN todos t ON t.list_id = l.id WHERE l.id = $1"
    result = query(sql, list_id)

    x = result.map do |tuple|
      {name: tuple['name'], completed: convert_to_bool(tuple['completed'])}
    end
    p x
    x
  end

  def log_error(error)
    # @session[:error_message] = error
  end

  def log_success(success)
    # @session[:success_message] = success
  end

  def update_todo_status(list_id, todo_id, new_status)
    # list = find_list(list_id)
    # todo = list[:todos].find { |todo| todo[:id] == todo_id }
    # todo[:completed] = new_status
  end

  def mark_all_todos_as_completed(list_id)
    # list = find_list(list_id)
    # list[:todos].each do |todo|
    #   todo[:completed] = true
    # end
  end

  def update_list_name(id, list_name)
    # list = find_list(id)
    # list[:name] = list_name
  end

  def create_new_todo(list_id, todo_name)
    # list = find_list(list_id)
    # id = next_element_id(list[:todos])
    # list[:todos] << { id: id, name: todo_name, completed: false }
  end

  private

  def convert_to_bool(string)
    string == 't'
  end
end
