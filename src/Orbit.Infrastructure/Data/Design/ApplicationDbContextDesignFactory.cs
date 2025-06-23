using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;
using Orbit.Infrastructure.Data.Contexts;

namespace Orbit.Infrastructure.Data.Design;

public class ApplicationDbContextDesignFactory : IDesignTimeDbContextFactory<ApplicationDbContext>
{
    public ApplicationDbContext CreateDbContext(string[] args)
    {
        string connectionString;
        connectionString = Environment.GetEnvironmentVariable("DB_CONNECTION")
        ?? throw new InvalidOperationException("The environment variable DB_CONNECTION with the database connection string cannot be empty.");

        var optionsBuilder = new DbContextOptionsBuilder<ApplicationDbContext>();
        optionsBuilder.UseMySql(connectionString, ServerVersion.AutoDetect(connectionString));

        return new ApplicationDbContext(optionsBuilder.Options);
    }
}
