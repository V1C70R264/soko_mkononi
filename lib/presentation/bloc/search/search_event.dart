// lib/presentation/bloc/search/search_event.dart
import 'product_feed_type.dart';

abstract class SearchEvent {}

/// Types into the search box, or an empty string for "View All".
/// Always targets the viewAll feed.
class SearchQueryChanged extends SearchEvent {
  final String query;
  SearchQueryChanged(this.query);
}

/// User tapped a different tab. If that feed has never been loaded,
/// triggers its first page fetch; otherwise just switches which feed
/// is displayed, instantly, from what's already cached.
class SwitchFeed extends SearchEvent {
  final ProductFeedType feed;
  SwitchFeed(this.feed);
}

/// Scrolled near the bottom — loads the next page for whichever feed
/// is currently active.
class LoadMoreActiveFeed extends SearchEvent {}