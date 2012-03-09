require "rack"
require_relative "spec_helper"
require "raptor"

describe Raptor::RouteOptions do
  let(:app_module) { stub(:app_module) }
  let(:parent_path) { "posts" }

  it "knows actions for exceptions" do
    options = Raptor::RouteOptions.new(app_module,
                                       "posts",
                                       :redirect => :show,
                                       IndexError => :index)
    options.exception_actions.should == {IndexError => :index}
  end

  context "responders" do
    let(:resource) do
      resource = stub(:path_component => "/posts", :one_presenter => stub)
    end

    it "creates responders for action templates" do
      responder = stub
      Raptor::ActionTemplateResponder.stub(:new).
        with(app_module, "post", parent_path, :show).
        and_return(responder)
      options = Raptor::RouteOptions.new(app_module,
                                         parent_path,
                                         :action => :show, :present => "post")
      options.responder.should == responder
    end

    it "renders the action's template by default" do
      template_responder = stub
      Raptor::ActionTemplateResponder.stub(:new).
        with(app_module, "post", parent_path, :show).
        and_return(template_responder)
      options = Raptor::RouteOptions.new(app_module,
                                         parent_path,
                                         :action => :show, :present => "post")
      options.responder.should == template_responder
    end

    it "uses the explicit template if one is given" do
      template_responder = stub
      Raptor::TemplateResponder.stub(:new).
        with(app_module, "post", "show").
        and_return(template_responder)
      options = Raptor::RouteOptions.new(
        app_module, parent_path, :present => "post", :render => "show")
      options.responder.should == template_responder
    end
  end

  it "knows a custom constraint" do
    admin_constraint = stub
    constraints = stub(:matching => [admin_constraint])
    Raptor::Constraints.stub(:new) { constraints }
    options = Raptor::RouteOptions.new(
      app_module, parent_path, :if => :admin, :http_method => "arbitrary", :path => "arbitrary")
    options.constraints.should include(admin_constraint)
  end

  it "delegates to nothing when there's no :to" do
    options = Raptor::RouteOptions.new(Object, parent_path, {})
    injector = stub(:injector)
    the_delegate = stub(:the_delegate)
    injector.stub(:call).with(Raptor::NullDelegate.method(:do_nothing)).
      and_return(the_delegate)
    options.delegator.delegate(injector).should == the_delegate
  end
end

