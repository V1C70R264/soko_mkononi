abstract class SearchEvent {}

class SearchQueryChanged extends SearchEvent {
  final String query;
  SearchQueryChanged(this.query);
}

/// Fetch the next page for the current query. Ignored by the bloc if
/// there is no next page or a fetch is already in flight.
class SearchLoadMore extends SearchEvent {}