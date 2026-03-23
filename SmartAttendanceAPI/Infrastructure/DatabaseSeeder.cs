using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Options;
using SmartAttendanceAPI.Constants;
using SmartAttendanceAPI.Data;
using SmartAttendanceAPI.Helpers;

namespace SmartAttendanceAPI.Infrastructure;

public sealed class DatabaseSeeder
{
    private readonly ISqlConnectionFactory _connectionFactory;
    private readonly IPasswordHasher _passwordHasher;
    private readonly IConfiguration _configuration;
    private readonly ILogger<DatabaseSeeder> _logger;

    public DatabaseSeeder(
        ISqlConnectionFactory connectionFactory,
        IPasswordHasher passwordHasher,
        IConfiguration configuration,
        ILogger<DatabaseSeeder> logger)
    {
        _connectionFactory = connectionFactory;
        _passwordHasher = passwordHasher;
        _configuration = configuration;
        _logger = logger;
    }

    public async Task SeedAsync(CancellationToken cancellationToken = default)
    {
        var section = _configuration.GetSection("SeedAdmin");
        var username = section["Username"] ?? "admin";
        var password = section["Password"] ?? "Admin@123";

        const string sql = """
            IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE Username = @Username)
            BEGIN
                INSERT INTO dbo.Users (Username, PasswordHash, Role, CreatedAt)
                VALUES (@Username, @PasswordHash, @Role, GETDATE());
            END
            """;

        try
        {
            await using var connection = _connectionFactory.CreateConnection();
            await connection.OpenAsync(cancellationToken);

            await using var command = new SqlCommand(sql, connection);
            command.Parameters.AddWithValue("@Username", username);
            command.Parameters.AddWithValue("@PasswordHash", _passwordHasher.Hash(password));
            command.Parameters.AddWithValue("@Role", AppRoles.Admin);

            await command.ExecuteNonQueryAsync(cancellationToken);
            _logger.LogInformation("Default admin seed completed (skipped if admin username already exists).");
        }
        catch (SqlException ex)
        {
            _logger.LogWarning(ex, "Database seed skipped or failed. Ensure the database and schema are deployed.");
        }
    }
}
