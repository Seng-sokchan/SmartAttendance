using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Options;
using SmartAttendanceAPI.DTOs.Auth;
using SmartAttendanceAPI.Exceptions;
using SmartAttendanceAPI.Helpers;
using SmartAttendanceAPI.Options;
using SmartAttendanceAPI.Repositories;

namespace SmartAttendanceAPI.Services;

public sealed class AuthService : IAuthService
{
    private readonly IUserRepository _users;
    private readonly IPasswordHasher _passwordHasher;
    private readonly IJwtTokenFactory _jwtTokenFactory;
    private readonly JwtOptions _jwtOptions;

    public AuthService(
        IUserRepository users,
        IPasswordHasher passwordHasher,
        IJwtTokenFactory jwtTokenFactory,
        IOptions<JwtOptions> jwtOptions)
    {
        _users = users;
        _passwordHasher = passwordHasher;
        _jwtTokenFactory = jwtTokenFactory;
        _jwtOptions = jwtOptions.Value;
    }

    public async Task<LoginResponseDto> LoginAsync(LoginRequestDto request, CancellationToken cancellationToken = default)
    {
        try
        {
            var user = await _users.GetByUsernameAsync(request.Username, request.Password, cancellationToken);
            if (user is null || !_passwordHasher.Verify(request.Password, user.PasswordHash))
                throw new AppException("Invalid username or password.", StatusCodes.Status401Unauthorized);

            var token = _jwtTokenFactory.CreateToken(user.Id, user.Username, user.Role);
            var expires = DateTime.UtcNow.AddMinutes(_jwtOptions.ExpiryMinutes);

            return new LoginResponseDto
            {
                Token = token,
                Username = user.Username,
                Role = user.Role,
                ExpiresAtUtc = expires
            };
        }
        catch (SqlException ex)
        {
            throw new AppException(ex.Message);
        }
    }
}
