require "spec_helper"

describe ParamsCleaner do
  describe "allowed_params" do
    it "only returns whitelisted params in the clean_params call" do
      klass = Class.new do
        include ParamsCleaner

        allowed_params :root => [:foo, :bar]

        def params
          {
            :root => {
              :foo => "foo",
              :bar => "bar",
              :baz => "baz"
            }
          }
        end
      end

      instance = klass.new

      instance.clean_params(:root).should == {
        :foo => "foo",
        :bar => "bar"
      }
    end
  end
end
