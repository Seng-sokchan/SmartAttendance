using System.Security.Claims;

namespace SmartAttendanceAPI.Helpers;

public static class ClaimsExtensions
{
    public static int GetUserId(this ClaimsPrincipal user)
    {
        var value = user.FindFirstValue(ClaimTypes.NameIdentifier);
        if (value is null || !int.TryParse(value, out var id))
            throw new InvalidOperationException("User id claim is missing or invalid.");

        return id;
    }
}
