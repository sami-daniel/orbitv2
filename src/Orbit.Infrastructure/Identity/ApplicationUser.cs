using Microsoft.AspNetCore.Identity;

namespace Orbit.Infrastructure.Identity;

/// <summary>
/// A default implementation of <see cref="IdentityUser{String}"/> which uses a string (internally GUID) as a primary key
/// </summary>
public class ApplicationUser : IdentityUser
{
    /// <summary>
    /// The ApplicationUser real name.
    /// </summary>
    public required string Name { get; set; }
}
