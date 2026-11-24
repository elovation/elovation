# frozen_string_literal: true

BetterErrors::Middleware.allow_ip! '0.0.0.0/0' if Rails.env.development?
