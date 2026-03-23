using Microsoft.Data.SqlClient;
using SmartAttendanceAPI.DTOs.Attendance;
using SmartAttendanceAPI.Exceptions;
using SmartAttendanceAPI.Repositories;

namespace SmartAttendanceAPI.Services;

public sealed class AttendanceService : IAttendanceService
{
    private readonly IAttendanceRepository _attendance;

    public AttendanceService(IAttendanceRepository attendance)
    {
        _attendance = attendance;
    }

    public async Task<CheckInResponseDto> CheckInAsync(int userId, LocationRequestDto request, CancellationToken cancellationToken = default)
    {
        try
        {
            var id = await _attendance.CheckInAsync(userId, request.Latitude, request.Longitude, cancellationToken);
            return new CheckInResponseDto { AttendanceId = id };
        }
        catch (SqlException ex)
        {
            throw new AppException(ex.Message);
        }
    }

    public async Task<CheckOutResponseDto> CheckOutAsync(int userId, LocationRequestDto request, CancellationToken cancellationToken = default)
    {
        try
        {
            await _attendance.CheckOutAsync(userId, request.Latitude, request.Longitude, cancellationToken);
            return new CheckOutResponseDto();
        }
        catch (SqlException ex)
        {
            throw new AppException(ex.Message);
        }
    }

    public async Task<IReadOnlyList<AttendanceRecordDto>> GetMyRecordsAsync(int userId, CancellationToken cancellationToken = default)
    {
        try
        {
            return await _attendance.GetUserAttendanceAsync(userId, cancellationToken);
        }
        catch (SqlException ex)
        {
            throw new AppException(ex.Message);
        }
    }
}
