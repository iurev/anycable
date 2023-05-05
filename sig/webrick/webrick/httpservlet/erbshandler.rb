module WEBrick
  module HTTPServlet
    class ERBHandler < AbstractServlet
      def initialize: (untyped server, untyped name) -> void

      def do_GET: (untyped req, untyped res) -> untyped

      alias do_POST do_GET

      private

      def evaluate: (untyped erb, untyped servlet_request, untyped servlet_response) -> untyped
    end
  end
end
