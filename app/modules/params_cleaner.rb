module ParamsCleaner
  extend ActiveSupport::Concern

  def clean_params(root)
    params[root].slice(*self.class._allowed_params[root])
  end

  module ClassMethods
    def allowed_params(params_hash)
      @allowed_params = params_hash
    end

    def _allowed_params
      @allowed_params
    end
  end
end
