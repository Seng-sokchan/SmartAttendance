namespace SmartAttendanceAPI.DTOs.Attendance;

public sealed class CheckInResponseDto
{
    public int AttendanceId { get; set; }
    public string Message { get; set; } = "Check-in recorded.";
}
