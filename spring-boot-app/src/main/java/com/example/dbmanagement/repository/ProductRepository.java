package com.example.dbmanagement.repository;

import com.example.dbmanagement.entity.Product;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

@Repository
public interface ProductRepository extends JpaRepository<Product, Long> {
    
    /**
     * Find product by SKU
     */
    Optional<Product> findBySku(String sku);
    
    /**
     * Find products by active status
     */
    List<Product> findByIsActive(Boolean isActive);
    
    /**
     * Find products by category ID
     */
    List<Product> findByCategoryId(Long categoryId);
    
    /**
     * Find products by name containing (case-insensitive)
     */
    List<Product> findByNameContainingIgnoreCase(String name);
    
    /**
     * Find products by price range
     */
    List<Product> findByPriceBetween(BigDecimal minPrice, BigDecimal maxPrice);
    
    /**
     * Find products with stock quantity greater than specified amount
     */
    List<Product> findByStockQuantityGreaterThan(Integer stockQuantity);
    
    /**
     * Find products with stock quantity less than specified amount
     */
    List<Product> findByStockQuantityLessThan(Integer stockQuantity);
    
    /**
     * Check if SKU exists
     */
    boolean existsBySku(String sku);
    
    /**
     * Find active products by category
     */
    @Query("SELECT p FROM Product p WHERE p.categoryId = :categoryId AND p.isActive = true")
    List<Product> findActiveProductsByCategory(@Param("categoryId") Long categoryId);
    
    /**
     * Find products with low stock (less than specified threshold)
     */
    @Query("SELECT p FROM Product p WHERE p.stockQuantity < :threshold AND p.isActive = true")
    List<Product> findProductsWithLowStock(@Param("threshold") Integer threshold);
    
    /**
     * Find products by price range and category
     */
    @Query("SELECT p FROM Product p WHERE p.price BETWEEN :minPrice AND :maxPrice AND p.categoryId = :categoryId AND p.isActive = true")
    List<Product> findByPriceRangeAndCategory(@Param("minPrice") BigDecimal minPrice, 
                                               @Param("maxPrice") BigDecimal maxPrice, 
                                               @Param("categoryId") Long categoryId);
    
    /**
     * Count active products
     */
    @Query("SELECT COUNT(p) FROM Product p WHERE p.isActive = true")
    long countActiveProducts();
    
    /**
     * Calculate total inventory value
     */
    @Query("SELECT SUM(p.price * p.stockQuantity) FROM Product p WHERE p.isActive = true")
    BigDecimal calculateTotalInventoryValue();
}
