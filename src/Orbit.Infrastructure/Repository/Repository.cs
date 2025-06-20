using Microsoft.EntityFrameworkCore;
using Orbit.Core.Repository;

namespace Orbit.Infrastructure.Repository;

/// <summary>
/// Provides a base implementation of the generic repository pattern using Entity Framework Core.
/// </summary>
/// <typeparam name="T">The type of the entity.</typeparam>
public abstract class Repository<T> : IRepository<T> where T : class
{
    /// <summary>
    /// The database context used by the repository.
    /// </summary>
    protected readonly DbContext _context;

    /// <summary>
    /// Initializes a new instance of the <see cref="Repository{T}"/> class.
    /// </summary>
    /// <param name="context">The database context.</param>
    protected Repository(DbContext context)
    {
        _context = context;
    }

    /// <inheritdoc/>
    public async Task<T?> GetAsync(int id)
    {
        return await _context.Set<T>().FindAsync(id);
    }

    /// <inheritdoc/>
    public async Task<IEnumerable<T>> GetAllAsync()
    {
        return await _context.Set<T>().ToListAsync();
    }

    /// <inheritdoc/>
    public async Task AddAsync(T entity)
    {
        if (entity == null) throw new ArgumentNullException(nameof(entity), "Entity cannot be null.");
        await _context.Set<T>().AddAsync(entity);
    }

    /// <inheritdoc/>
    public Task UpdateAsync(T entity)
    {
        if (entity == null) throw new ArgumentNullException(nameof(entity), "Entity cannot be null.");
        // This will mark the entity for update, so it will be removed when SaveChanges is called..
        _context.Set<T>().Update(entity);
        return Task.CompletedTask;
    }

    /// <inheritdoc/>
    public Task DeleteAsync(T entity)
    {
        if (entity == null) throw new ArgumentNullException(nameof(entity), "Entity cannot be null.");
        // This will mark the entity for deletion, so it will be removed when SaveChanges is called..
        _context.Set<T>().Remove(entity);
        return Task.CompletedTask;
    }
}