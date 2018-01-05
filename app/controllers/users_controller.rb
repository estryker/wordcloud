class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :finish_signup]

  before_action :authenticate, :only => [:edit, :update, :show]
  before_action :correct_user, :only => [:edit, :update, :show]

  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json

 def show

   @title = @user.name
   @role_description = Role.find(@user.role_id).name
   
   @num_items = @user.items.length # can I do a select count query type thing to make this more efficient??
   # @num_items = Item.where(:user_email => @user.email).count
   
   respond_to do | format |
     # format.json {render :json=> @items}
     # format.xml {render :xml=> @items}
     format.html {render 'show'}
   end
 end

 # GET /users/new
 def new
   @user = User.new
 end

 # GET /users/1/edit
 def edit
   @user_role_name = Role.find(User.find(params[:id]).role_id).name
   puts "editing user with role: #{@user_role_name}"
 end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end
 
  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    # TODO: Note that devise will make sure that the email address is confirmed if changed

    role_names = Role.all.map {|r| r.name }

    # this is a hack to allow the updating of roles by ID
    # If I put role_name in the form, the Role model complains
    # that role_name isn't included. So convert the parameter
    # into its corresponding ID
    # Note that the user_params method uses caching to make this work
    if role_names.include? user_params['role_id']
      user_params['role_id'] = Role.where(name: user_params['role_id']).first.id 
    end

    puts "Updating user #{@user.id}"
    respond_to do |format|
      if @user.update(user_params)
        
        format.html do 
          # puts "user params: #{user_params.inspect}"
          if user_params.empty?
            redirect_to @user
          else
            redirect_to @user, notice: 'User successfully updated.' 
          end
        end
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to root_path, notice: 'User was successfully logged out.' }
      format.json { head :no_content }
    end
  end

  # GET/PATCH /users/:id/finish_signup
  def finish_signup
    # authorize! :update, @user 
    if request.patch? && params[:user] #&& params[:user][:email]
      if @user.update(user_params)
        @user.skip_reconfirmation!
        sign_in(@user, :bypass => true)
        redirect_to @user, notice: 'A confirmation email has been sent.'
      else
        @show_errors = true
      end
    end
  end
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      permit_params = [:name, :email]

      # only allow admins to update the roles of users. 
      # I'm allowing it to be updated by role_id or role_name
      if current_user.admin?     
        permit_params << :role_id
        permit_params << :role_name
      end
      # cache the results, which helps us to update the Hash
      @user_params ||= params.require(:user).permit(*permit_params)
    end   

    def authenticate
      deny_access unless signed_in? 
    end
    
    def correct_user
      @user = User.find(params[:id])
      redirect_to(index_path) unless current_user == @user || current_user.admin?
    end

end
