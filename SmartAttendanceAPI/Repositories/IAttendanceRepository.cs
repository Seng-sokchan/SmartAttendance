using SmartAttendanceAPI.DTOs.Attendance;

namespace SmartAttendanceAPI.Repositories;

public interface IAttendanceRepository
{
    Task<int> CheckInAsync(int userId, double latitude, double longitude, CancellationToken cancellationToken = default);
    Task CheckOutAsync(int userId, double latitude, double longitude, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<AttendanceRecordDto>> GetUserAttendanceAsync(int userId, CancellationToken cancellationToken = default);
}
