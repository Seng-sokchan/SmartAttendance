using SmartAttendanceAPI.DTOs.Auth;

namespace SmartAttendanceAPI.Services;

public interface IAuthService
{
    Task<LoginResponseDto> LoginAsync(LoginRequestDto request, CancellationToken cancellationToken = default);
}
