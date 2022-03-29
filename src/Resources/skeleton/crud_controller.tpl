<?= "<?php\n"; ?>

namespace <?= $namespace; ?>;

use <?= $entity_fqcn; ?>;
use App\Factory\FieldFactory;
use App\Factory\FilterFactory;
use App\Repository\<?= $entity_class_name; ?>Repository;
use App\Service\Refractor;
use Doctrine\ORM\QueryBuilder;
use EasyCorp\Bundle\EasyAdminBundle\Collection\FieldCollection;
use EasyCorp\Bundle\EasyAdminBundle\Collection\FilterCollection;
use EasyCorp\Bundle\EasyAdminBundle\Config\Actions;
use EasyCorp\Bundle\EasyAdminBundle\Config\Crud;
use EasyCorp\Bundle\EasyAdminBundle\Config\Filters;
use EasyCorp\Bundle\EasyAdminBundle\Dto\EntityDto;
use EasyCorp\Bundle\EasyAdminBundle\Dto\SearchDto;
use EasyCorp\Bundle\EasyAdminBundle\Orm\EntityRepository;
use Symfony\Component\Security\Core\Authorization\AuthorizationCheckerInterface;

class <?= $class_name; ?> extends CentotaureCrudController
{
    public string $className = <?= $entity_class_name; ?>::class;
    public string $labelClassName = '<?= \App\Service\Refractor::transformCamelCaseToLowerCase($entity_class_name) ?>';

    private <?= $entity_class_name; ?>Repository $<?= lcfirst($entity_class_name); ?>Repository;
    private AuthorizationCheckerInterface $authorizationChecker;


    public function __construct(
        <?= $entity_class_name; ?>Repository $<?= lcfirst($entity_class_name); ?>Repository,
        AuthorizationCheckerInterface $authorizationChecker,
        FieldFactory $fieldFactory,
        FilterFactory $filterFactory,
        Refractor $refractor,
    )
    {
        parent::__construct($fieldFactory, $filterFactory, $refractor);
        $this-><?= lcfirst($entity_class_name); ?>Repository = $<?= lcfirst($entity_class_name); ?>Repository;
        $this->authorizationChecker = $authorizationChecker;
    }

    public function createIndexQueryBuilder(
        SearchDto $searchDto,
        EntityDto $entityDto,
        FieldCollection $fields,
        FilterCollection $filters
    ): QueryBuilder
    {
        $request = $this->get(EntityRepository::class)->createQueryBuilder($searchDto, $entityDto, $fields, $filters);

        return $this-><?= lcfirst($entity_class_name); ?>Repository->createIndexQueryBuilder($request);
    }

    public function configureCrud(Crud $crud): Crud
    {
        return $this->CentotaureConfigureCrud($crud);
    }

    public function configureFilters(Filters $filters): Filters
    {
        return $this->generateFilters($filters);
    }

    public static function getEntityFqcn(): string
    {
        return <?= $entity_class_name; ?>::class;
    }

    public function configureFields(string $pageName): iterable
    {
        return $this->generateFields()
    }

    public function configureActions(Actions $actions): Actions
    {
        if ($this->authorizationChecker->isGranted('ROLE_SUPER_ADMIN') === true) {
            return $this->getAllActions($actions);
        }
        if ($this->authorizationChecker->isGranted('ROLE_ADMIN') === true) {
            return $this->getDetailAction($actions);
        }

        $this->removeAllActions($actions);
        return $actions;
    }
}
