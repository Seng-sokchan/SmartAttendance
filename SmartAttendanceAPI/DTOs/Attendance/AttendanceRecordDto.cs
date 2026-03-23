namespace SmartAttendanceAPI.DTOs.Attendance;

public sealed class AttendanceRecordDto
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public DateTime? CheckInTime { get; set; }
    public DateTime? CheckOutTime { get; set; }
    public DateOnly Date { get; set; }
    public double Latitude { get; set; }
    public double Longitude { get; set; }
}
