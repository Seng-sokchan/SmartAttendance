using SmartAttendanceAPI.DTOs.Attendance;

namespace SmartAttendanceAPI.Services;

public interface IAttendanceService
{
    Task<CheckInResponseDto> CheckInAsync(int userId, LocationRequestDto request, CancellationToken cancellationToken = default);
    Task<CheckOutResponseDto> CheckOutAsync(int userId, LocationRequestDto request, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<AttendanceRecordDto>> GetMyRecordsAsync(int userId, CancellationToken cancellationToken = default);
}
