module BackburnerSpec::Helpers
  def with_backburner
    original = BackburnerSpec.inline
    begin
      BackburnerSpec.inline = true
      yield
    ensure
      BackburnerSpec.inline = original
    end
  end

  def without_backburner_spec
    original = BackburnerSpec.disable_ext
    begin
      BackburnerSpec.disable_ext = true
      yield
    ensure
      BackburnerSpec.disable_ext = original
    end
  end
end