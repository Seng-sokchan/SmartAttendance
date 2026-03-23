using Microsoft.Data.SqlClient;
using SmartAttendanceAPI.Constants;
using SmartAttendanceAPI.Data;
using SmartAttendanceAPI.DTOs.Attendance;

namespace SmartAttendanceAPI.Repositories;

public sealed class AttendanceRepository : IAttendanceRepository
{
    private readonly ISqlConnectionFactory _connectionFactory;

    public AttendanceRepository(ISqlConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    public async Task<int> CheckInAsync(int userId, double latitude, double longitude, CancellationToken cancellationToken = default)
    {
        await using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        await using var command = new SqlCommand(StoredProcedureNames.CheckIn, connection)
        {
            CommandType = System.Data.CommandType.StoredProcedure
        };

        command.Parameters.AddWithValue("@UserId", userId);
        command.Parameters.AddWithValue("@Latitude", latitude);
        command.Parameters.AddWithValue("@Longitude", longitude);

        await using var reader = await command.ExecuteReaderAsync(cancellationToken);
        if (!await reader.ReadAsync(cancellationToken))
            throw new InvalidOperationException("Check-in did not return an identifier.");

        return reader.GetInt32(reader.GetOrdinal("AttendanceId"));
    }

    public async Task CheckOutAsync(int userId, double latitude, double longitude, CancellationToken cancellationToken = default)
    {
        await using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        await using var command = new SqlCommand(StoredProcedureNames.CheckOut, connection)
        {
            CommandType = System.Data.CommandType.StoredProcedure
        };

        command.Parameters.AddWithValue("@UserId", userId);
        command.Parameters.AddWithValue("@Latitude", latitude);
        command.Parameters.AddWithValue("@Longitude", longitude);

        await using var reader = await command.ExecuteReaderAsync(cancellationToken);
        if (!await reader.ReadAsync(cancellationToken))
            throw new InvalidOperationException("Check-out did not return a result.");

        var rows = reader.GetInt32(reader.GetOrdinal("RowsUpdated"));
        if (rows != 1)
            throw new InvalidOperationException("Check-out could not update the record.");
    }

    public async Task<IReadOnlyList<AttendanceRecordDto>> GetUserAttendanceAsync(int userId, CancellationToken cancellationToken = default)
    {
        var list = new List<AttendanceRecordDto>();

        await using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        await using var command = new SqlCommand(StoredProcedureNames.GetUserAttendance, connection)
        {
            CommandType = System.Data.CommandType.StoredProcedure
        };

        command.Parameters.AddWithValue("@UserId", userId);

        await using var reader = await command.ExecuteReaderAsync(cancellationToken);
        while (await reader.ReadAsync(cancellationToken))
        {
            var date = reader.GetDateTime(reader.GetOrdinal("Date"));
            list.Add(new AttendanceRecordDto
            {
                Id = reader.GetInt32(reader.GetOrdinal("Id")),
                UserId = reader.GetInt32(reader.GetOrdinal("UserId")),
                CheckInTime = reader.IsDBNull(reader.GetOrdinal("CheckInTime"))
                    ? null
                    : reader.GetDateTime(reader.GetOrdinal("CheckInTime")),
                CheckOutTime = reader.IsDBNull(reader.GetOrdinal("CheckOutTime"))
                    ? null
                    : reader.GetDateTime(reader.GetOrdinal("CheckOutTime")),
                Date = DateOnly.FromDateTime(date),
                Latitude = reader.GetDouble(reader.GetOrdinal("Latitude")),
                Longitude = reader.GetDouble(reader.GetOrdinal("Longitude"))
            });
        }

        return list;
    }
}
