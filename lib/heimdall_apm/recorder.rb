module HeimdallApm
  # TODO: Maybe not needed if we keep transaction logic within visitors
  class Recorder
    def record(request)
      request.record
    end
  end
end
