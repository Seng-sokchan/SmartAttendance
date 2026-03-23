namespace SmartAttendanceAPI.DTOs.Admin;

public sealed class CreateUserResponseDto
{
    public int UserId { get; set; }
    public string Username { get; set; } = string.Empty;
    public string Role { get; set; } = string.Empty;
}
