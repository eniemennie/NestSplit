enum SwapStatus { pending, approved, declined }

/// A request to trade chores. "Incoming" means someone asked the current user.
class SwapRequest {
  const SwapRequest({
    required this.id,
    required this.requesterId,
    required this.targetId,
    required this.offeredChore,
    required this.reason,
    this.requestedChore,
    this.status = SwapStatus.pending,
  });

  final String id;
  final String requesterId;
  final String targetId;
  final String offeredChore;
  final String? requestedChore;
  final String reason;
  final SwapStatus status;

  SwapRequest copyWith({SwapStatus? status}) {
    return SwapRequest(
      id: id,
      requesterId: requesterId,
      targetId: targetId,
      offeredChore: offeredChore,
      requestedChore: requestedChore,
      reason: reason,
      status: status ?? this.status,
    );
  }
}
