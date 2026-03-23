using Microsoft.Data.SqlClient;
using SmartAttendanceAPI.Constants;
using SmartAttendanceAPI.DTOs.Admin;
using SmartAttendanceAPI.Exceptions;
using SmartAttendanceAPI.Helpers;
using SmartAttendanceAPI.Repositories;

namespace SmartAttendanceAPI.Services;

public sealed class AdminService : IAdminService
{
    private readonly IUserRepository _users;
    private readonly IPasswordHasher _passwordHasher;

    public AdminService(IUserRepository users, IPasswordHasher passwordHasher)
    {
        _users = users;
        _passwordHasher = passwordHasher;
    }

    public async Task<CreateUserResponseDto> CreateUserAsync(CreateUserRequestDto request, CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(request.Username) || string.IsNullOrWhiteSpace(request.Password))
            throw new AppException("Username and password are required.");

        var role = request.Role.Trim();
        if (role != AppRoles.Admin && role != AppRoles.User)
            throw new AppException("Role must be Admin or User.");

        var hash = _passwordHasher.Hash(request.Password);

        try
        {
            var id = await _users.CreateUserAsync(request.Username.Trim(), hash, role, cancellationToken);
            return new CreateUserResponseDto
            {
                UserId = id,
                Username = request.Username.Trim(),
                Role = role
            };
        }
        catch (SqlException ex)
        {
            throw new AppException(ex.Message);
        }
    }

    public async Task<IReadOnlyList<UserListItemDto>> GetAllUsersAsync(CancellationToken cancellationToken = default)
    {
        try
        {
            return await _users.GetAllUsersAsync(cancellationToken);
        }
        catch (SqlException ex)
        {
            throw new AppException(ex.Message);
        }
    }
}
